import Foundation
import Combine
import CoreLocation
import SwiftUI
import SwiftData
import Adhan

@MainActor
final class TrackerViewModel: ObservableObject {

    // MARK: - Published
    @Published var prayers: [TrackerPrayer] = []
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var showingHijri: Bool = false
    @Published var freezeOverlay: Bool = false

    // MARK: - Dependencies
    let locationManager = MiniLocationManager()

    private var context: ModelContext?
    private var todayRecord: PrayerDay?

    private let cache = PrayerTimesCache()
    private let prayerSync = PrayerSyncService.shared

    private var ticker: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let tickSeconds: TimeInterval = 30

    // Debounced Firestore sync
    private var syncTask: Task<Void, Never>?
    private let syncDebounceDelay: TimeInterval = 2.0

    // MARK: - Configure / Lifecycle

    func configure(context: ModelContext) {
        self.context = context
        refreshTodayRecord()          // fetch/create using startOfDay
        refreshUIFromLocalState()     // apply stored completion state to UI if we already have times
        print("🔧 Configured. Today record: \(todayRecord?.dayKey ?? "nil"), completed: \(todayRecord?.completed ?? [:])")
    }

    func onAppear() {
        if cache.shouldInvalidate() {
            cache.clear()
        }

        // Always refresh the record from SwiftData when returning to this tab
        refreshTodayRecord()
        refreshUIFromLocalState()

        // If we already have coordinate, load immediately (uses stored completion state)
        if let coord = coordinate {
            loadPrayers(for: coord, on: Date())
        }

        locationManager.request()

        locationManager.$coordinate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coord in
                guard let self else { return }
                self.coordinate = coord
                if let c = coord {
                    self.loadPrayers(for: c, on: Date())
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSNotification.Name("AsrMadhabChanged"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.cache.clear()
                if let coord = self.coordinate {
                    self.loadPrayers(for: coord, on: Date())
                }
            }
            .store(in: &cancellables)

        startTicker()
    }

    func onDisappear() {
        ticker?.cancel()
        ticker = nil
        cancellables.removeAll()
        showingHijri = false

        syncTask?.cancel()
        syncTask = nil
    }

    // MARK: - Actions

    func setFreezeOverlay(_ enabled: Bool) {
        freezeOverlay = enabled
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        guard let ctx = context else { return }

        refreshTodayRecord()
        guard let record = todayRecord else { return }

        record.isFrozen = enabled

        do {
            try ctx.save()
            debouncedSyncToFirestore(record: record)
        } catch {
            print("❌ Failed to save freeze status: \(error)")
        }
    }

    func toggleDateCalendar() {
        showingHijri.toggle()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func togglePrayer(at index: Int, allowAny: Bool = false) {
        guard prayers.indices.contains(index) else { return }

        if freezeOverlay {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }

        if !allowAny {
            let now = Date()
            guard prayers[index].canMark(at: now) else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                return
            }
        }

        guard let ctx = context else { return }

        // Ensure we’re updating the correct “today” record
        refreshTodayRecord()
        guard let record = todayRecord else { return }

        let prayerName = prayers[index].name
        let key = keyForPrayerName(prayerName)

        // Update UI first
        prayers[index].done.toggle()
        let newValue = prayers[index].done

        // Update SwiftData (replace entire dict to ensure change detection)
        var updated = record.completed
        updated[key] = newValue
        record.completed = updated

        print("💾 Saving \(key) = \(newValue). Completed now: \(record.completed)")

        do {
            try ctx.save()

            // Re-apply stored truth back onto the UI (prevents weird merge/caching issues)
            refreshUIFromLocalState()

            // Firestore sync (debounced)
            debouncedSyncToFirestore(record: record)
        } catch {
            // Revert UI on failure
            prayers[index].done.toggle()
            print("❌ SwiftData save error: \(error)")
        }
    }

    // MARK: - Watch Integration

    func handleWatchPrayerDetection() -> String? {
        guard let coord = coordinate else {
            print("No coordinate available for prayer detection")
            return nil
        }

        guard let prayerName = PrayerDetectionService.determinePrayerToTick(coordinate: coord) else {
            print("No valid prayer window is currently active")
            return nil
        }

        guard let index = prayers.firstIndex(where: { $0.name.caseInsensitiveCompare(prayerName) == .orderedSame }) else {
            print("Prayer \(prayerName) not found in prayers list")
            return nil
        }

        if freezeOverlay || prayers[index].done {
            return nil
        }

        guard let ctx = context else { return nil }

        refreshTodayRecord()
        guard let record = todayRecord else { return nil }

        prayers[index].done = true

        let key = keyForPrayerName(prayerName)
        var updated = record.completed
        updated[key] = true
        record.completed = updated

        do {
            try ctx.save()
            print("✅ Saved \(key) = true to SwiftData (from Watch)")

            refreshUIFromLocalState()
            debouncedSyncToFirestore(record: record)
            loadPrayers(for: coord, on: Date())
            return prayerName
        } catch {
            prayers[index].done = false
            print("❌ SwiftData save failed (Watch): \(error)")
            return nil
        }
    }

    // MARK: - Date display

    func displayDateString(
        gregorianTemplate: String = "EEEE d MMMM",
        hijriTemplate: String = "d MMMM y",
        date: Date = Date()
    ) -> String {
        let usingHijri = showingHijri
        let cal: Calendar = usingHijri ? Calendar(identifier: .islamicUmmAlQura) : Calendar(identifier: .gregorian)
        let template = usingHijri ? hijriTemplate : gregorianTemplate

        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.calendar = cal
        f.setLocalizedDateFormatFromTemplate(template)
        return f.string(from: date)
    }

    // MARK: - Core loading

    private func loadPrayers(for coord: CLLocationCoordinate2D, on date: Date) {
        refreshTodayRecord()
        let completed = todayRecord?.completed ?? [:]
        freezeOverlay = todayRecord?.isFrozen ?? false

        // Use cached prayer times, but NEVER cached completion state
        if cache.isValid(for: date, coordinate: coord),
           let cached = cache.load() {
            let merged = cache.toTrackerPrayers(cached: cached, completed: completed)
            self.prayers = merged
            return
        }

        let simple = computePrayerItems(for: coord, date: date)

        let coordinates = Coordinates(latitude: coord.latitude, longitude: coord.longitude)
        var params = CalculationMethod.moonsightingCommittee.params
        params.madhab = PrefKeys.getAsrMadhab()
        params.highLatitudeRule = .middleOfTheNight

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent

        let compsToday = cal.dateComponents([.year, .month, .day], from: date)
        guard
            let todayPT = PrayerTimes(coordinates: coordinates, date: compsToday, calculationParameters: params),
            let tomorrow = cal.date(byAdding: .day, value: 1, to: date)
        else {
            self.prayers = []
            return
        }

        let compsTomorrow = cal.dateComponents([.year, .month, .day], from: tomorrow)
        guard let tomorrowPT = PrayerTimes(coordinates: coordinates, date: compsTomorrow, calculationParameters: params) else {
            self.prayers = []
            return
        }

        let names = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        let starts = [todayPT.fajr, todayPT.dhuhr, todayPT.asr, todayPT.maghrib, todayPT.isha]
        let nextDayFajr = tomorrowPT.fajr

        var merged: [TrackerPrayer] = []
        for i in 0..<names.count {
            let name = names[i]
            let label = simple.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }?.time ?? "--:--"
            let start = starts[i]
            let next  = (i < starts.count - 1) ? starts[i + 1] : nextDayFajr
            let key   = keyForPrayerName(name)
            let done  = completed[key] ?? false

            merged.append(TrackerPrayer(name: name, timeLabel: label, start: start, nextStart: next, done: done))
        }

        cache.save(prayers: merged, for: date, coordinate: coord)
        self.prayers = merged
    }

    // MARK: - SwiftData record logic (FIXED)

    /// Always anchor to local start-of-day so "today" is consistent across saves/loads/tab switches.
    private func anchoredDayDate(for date: Date) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent
        return cal.startOfDay(for: date)
    }

    private func refreshTodayRecord() {
        guard context != nil else { return }
        todayRecord = fetchOrCreateRecord(for: anchoredDayDate(for: Date()))
        freezeOverlay = todayRecord?.isFrozen ?? false
    }

    private func fetchOrCreateRecord(for anchoredDate: Date) -> PrayerDay {
        guard let ctx = context else {
            fatalError("ModelContext not configured. Call configure(context:) before use.")
        }

        // IMPORTANT: key must be based on anchoredDate (startOfDay), not Date()
        let key = PrayerDay.key(for: anchoredDate)
        let predicate = #Predicate<PrayerDay> { $0.dayKey == key }
        let desc = FetchDescriptor<PrayerDay>(predicate: predicate)

        do {
            let results = try ctx.fetch(desc)
            if let existing = results.first {
                return existing
            }
        } catch {
            print("❌ Error fetching record for \(key): \(error)")
        }

        // Create if missing
        let created = PrayerDay(date: anchoredDate, completed: [:])
        ctx.insert(created)

        do {
            try ctx.save()
            print("📝 Created new record for \(key)")
        } catch {
            print("❌ Error saving new record for \(key): \(error)")
        }

        return created
    }

    /// Re-applies SwiftData completion state onto the current `prayers` array (without recomputing times).
    private func refreshUIFromLocalState() {
        guard let record = todayRecord else { return }
        let completed = record.completed

        guard !prayers.isEmpty else { return }

        var updated = prayers
        for i in updated.indices {
            let key = keyForPrayerName(updated[i].name)
            updated[i].done = completed[key] ?? false
        }
        prayers = updated
    }

    private func keyForPrayerName(_ name: String) -> String {
        // Keep your existing convention, but now it’s consistently used everywhere.
        name.uppercased()
    }

    // MARK: - Debounced Firestore Sync

    private func debouncedSyncToFirestore(record: PrayerDay) {
        syncTask?.cancel()
        syncTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(syncDebounceDelay * 1_000_000_000))
            guard !Task.isCancelled else { return }

            do {
                try await prayerSync.syncPrayerDay(record)
            } catch {
                print("⚠️ Firestore sync failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - UI ticker

    private func startTicker() {
        ticker?.cancel()
        ticker = Timer.publish(every: tickSeconds, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }
}

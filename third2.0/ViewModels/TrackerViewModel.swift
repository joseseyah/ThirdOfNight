import Foundation
import Combine
import CoreLocation
import SwiftUI
import SwiftData
import Adhan

@MainActor
final class TrackerViewModel: ObservableObject {

    @Published var prayers: [TrackerPrayer] = []
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var showingHijri: Bool = false

    @Published var freezeOverlay: Bool = false

    let locationManager = MiniLocationManager()

    private var context: ModelContext?
    private var todayRecord: PrayerDay?

    private var ticker: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let tickSeconds: TimeInterval = 30

    func configure(context: ModelContext) {
        self.context = context
        self.todayRecord = fetchOrCreateToday(for: Date())
    }

    func onAppear() {
        locationManager.request()

        locationManager.$coordinate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coord in
                guard let self else { return }
                self.coordinate = coord
                if let c = coord {
                    self.todayRecord = self.fetchOrCreateToday(for: Date())
                    self.loadPrayers(for: c, on: Date())
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
    }

    func setFreezeOverlay(_ enabled: Bool) {
        freezeOverlay = enabled
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

        prayers[index].done.toggle()

        guard let ctx = context else { return }
        let record = todayRecord ?? fetchOrCreateToday(for: Date())
        let key = keyForPrayerName(prayers[index].name)
        record.completed[key] = prayers[index].done
        do { try ctx.save() } catch {
            prayers[index].done.toggle()
            print("SwiftData save failed: \(error)")
        }
        todayRecord = record
    }


    func displayDateString(gregorianTemplate: String = "EEEE d MMMM",
                           hijriTemplate: String = "d MMMM y",
                           date: Date = Date()) -> String {
        let usingHijri = showingHijri
        let cal: Calendar = usingHijri
            ? Calendar(identifier: .islamicUmmAlQura)
            : Calendar(identifier: .gregorian)
        let template = usingHijri ? hijriTemplate : gregorianTemplate

        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.calendar = cal
        f.setLocalizedDateFormatFromTemplate(template)
        return f.string(from: date)
    }

    private func loadPrayers(for coord: CLLocationCoordinate2D, on date: Date) {
        let simple = computePrayerItems(for: coord, date: date)

        let coordinates = Coordinates(latitude: coord.latitude, longitude: coord.longitude)
        var params = CalculationMethod.moonsightingCommittee.params
        params.madhab = .shafi
        params.highLatitudeRule = .middleOfTheNight

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent

        let compsToday = cal.dateComponents([.year, .month, .day], from: date)
        guard
            let todayPT = PrayerTimes(coordinates: coordinates, date: compsToday, calculationParameters: params),
            let tomorrow = cal.date(byAdding: .day, value: 1, to: date),
            let ctx = context
        else {
            self.prayers = []
            return
        }

        let compsTomorrow = cal.dateComponents([.year, .month, .day], from: tomorrow)
        guard let tomorrowPT = PrayerTimes(coordinates: coordinates, date: compsTomorrow, calculationParameters: params) else {
            self.prayers = []
            return
        }

        let record = todayRecord ?? fetchOrCreateToday(for: date)
        let completed = record.completed

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

        self.prayers = merged
        self.todayRecord = record
        try? ctx.save()
    }

    // MARK: - SwiftData helpers
    private func fetchOrCreateToday(for date: Date) -> PrayerDay {
        guard let ctx = context else { fatalError("ModelContext not configured. Call configure(context:) before use.") }
        let key = PrayerDay.key(for: date)
        let predicate = #Predicate<PrayerDay> { $0.dayKey == key }
        let desc = FetchDescriptor<PrayerDay>(predicate: predicate)
        if let existing = try? ctx.fetch(desc).first {
            return existing
        }
        let created = PrayerDay(date: date, completed: [:])
        ctx.insert(created)
        return created
    }

    private func keyForPrayerName(_ name: String) -> String {
        name.uppercased()
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

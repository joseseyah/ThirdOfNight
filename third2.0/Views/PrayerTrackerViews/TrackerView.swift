import SwiftUI
import CoreLocation
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = TrackerViewModel()

    @State private var showAdsSheet = false
    @State private var showLastThirdSheet = false
    @State private var showFreezeSheet = false
    @State private var showTravelInfoSheet = false

    @AppStorage(PrefKeys.freezeOn) private var isFreezeOn: Bool = false
    @AppStorage("travel_mode_enabled") private var travelModeEnabled: Bool = false

    private let verticalNudge: CGFloat = 30
    private let sidePadding: CGFloat = 16
    private let headingGap: CGFloat = 10
    private let rowSpacing: CGFloat = 14
    private let sectionSpacing: CGFloat = 25

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            StarOverlay(count: 25, maxYFraction: 0.70, opacity: 0.28)
            MoonOverlay(
                assetName: "moon",
                size: 88,
                top: -10,
                leading: 30,
                opacity: 0.48,
                glowScale: 0.5,
                glowBlur: 0.15,
                glowOpacity: 0.3
            )

            if vm.coordinate != nil, !vm.prayers.isEmpty {
                VStack(spacing: sectionSpacing) {
                    header

                    Group {
                        if travelModeEnabled {
                          TravelCombineCard(
                              fajr:     travelRow(for: "fajr"),
                              dhuhr:    travelRow(for: "dhuhr"),
                              asr:      travelRow(for: "asr"),
                              maghrib:  travelRow(for: "maghrib"),
                              isha:     travelRow(for: "isha")
                          )

                        } else {
                            VStack(spacing: rowSpacing) {
                                ForEach(vm.prayers.indices, id: \.self) { i in
                                    let item = vm.prayers[i]
                                    PrayerRowView(
                                        name: item.name,
                                        time: item.timeLabel,
                                        isDone: vm.freezeOverlay ? true : item.done,
                                        isEnabled: item.canMark() && !vm.freezeOverlay
                                    ) {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                            vm.togglePrayer(at: i)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, sidePadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: verticalNudge)
            } else {
                LocationNotOnView(loc: vm.locationManager)
            }
        }

        .overlay(alignment: .bottomTrailing) {
            Button { showAdsSheet = true } label: {
                Image(systemName: "bag")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appBg)
                    .frame(width: 48, height: 48)
                    .background(Color.accentYellow)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                    .overlay(Circle().stroke(Color.stroke, lineWidth: 1))
                    .accessibilityLabel("Support us")
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }

        .overlay(alignment: .topTrailing) {
            let schedule = CurrentPrayerBadge.makeStandardSchedule { prayerDate($0) }
            CurrentPrayerBadge(schedule: schedule, outerPadding: .init())
                .safeAreaPadding([.top, .trailing], 18)
        }




        .sheet(isPresented: $showAdsSheet) {
            AdsSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .background(Color.appBg.ignoresSafeArea())
        }
        .sheet(isPresented: $showLastThirdSheet) {
            LastThirdSheetView(
                isha: prayerDate("isha"),
                maghrib: prayerDate("maghrib"),
                fajr: prayerDate("fajr"),
                timezone: TimeZone.current
            )
            .presentationDetents([.fraction(0.7), .large])
            .presentationDragIndicator(.visible)
            .background(Color.appBg.ignoresSafeArea())
        }
        .sheet(isPresented: $showFreezeSheet) {
            FreezeSheetView(isOn: $isFreezeOn)
        }
        .sheet(isPresented: $showTravelInfoSheet) {
            TravelInfoSheetView()
                .presentationDetents([.fraction(0.65), .large])
                .presentationDragIndicator(.visible)
                .background(Color.appBg.ignoresSafeArea())
        }

        .onAppear {
            vm.configure(context: modelContext)
            vm.onAppear()
            vm.setFreezeOverlay(isFreezeOn)
        }
        .onDisappear { vm.onDisappear() }
        .onChange(of: isFreezeOn) { vm.setFreezeOverlay($0) }
    }

    private var header: some View {
        VStack(spacing: headingGap) {
            ZStack {
                LocationHeader(loc: vm.locationManager)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { showLastThirdSheet = true }
                    .accessibilityAddTraits(.isButton)

                HStack {
                    Spacer()

                    if travelModeEnabled {
                        Button {
                            showTravelInfoSheet = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appBg)
                                .frame(width: 36, height: 36)
                                .background(Color.accentYellow)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                                .overlay(Circle().stroke(Color.stroke, lineWidth: 1))
                                .accessibilityLabel("Travel information")
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 16)
                    } else {
                        FreezeCircleButton(
                            isOn: $isFreezeOn,
                            onActivate: { showFreezeSheet = true }
                        )
                        .padding(.trailing, 16)
                    }
                }
            }

            Text(vm.displayDateString(gregorianTemplate: "EEEE d MMMM",
                                      hijriTemplate: "d MMMM"))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .onTapGesture { vm.toggleDateCalendar() }
                .animation(.easeInOut(duration: 0.15), value: vm.showingHijri)
                .accessibilityLabel(vm.showingHijri ? "Hijri date" : "Gregorian date")
        }
    }

    private func display(for key: String) -> PrayerDisplay? {
        vm.prayers.first {
            $0.name.localizedCaseInsensitiveContains(key)
        }.map { PrayerDisplay(name: $0.name, timeText: $0.timeLabel) }
    }

    private func travelRow(for key: String) -> TravelRowItem? {
        guard let idx = vm.prayers.firstIndex(where: { $0.name.localizedCaseInsensitiveContains(key) }) else { return nil }
        let p = vm.prayers[idx]

        let isEnabled = travelModeEnabled ? !vm.freezeOverlay : (p.canMark() && !vm.freezeOverlay)
        let isDone    = vm.freezeOverlay ? true : p.done

        return TravelRowItem(
            display: PrayerDisplay(name: p.name, timeText: p.timeLabel),
            isDone: isDone,
            isEnabled: isEnabled,
            onTap: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    vm.togglePrayer(at: idx, allowAny: travelModeEnabled)   // ← key change
                }
            }
        )
    }

}

private extension TrackerView {
    func prayerDate(_ name: String) -> Date? {
        let lower = name.lowercased()
        guard let item = vm.prayers.first(where: { $0.name.lowercased().contains(lower) }) else { return nil }

        let mirror = Mirror(reflecting: item)
        for key in ["date", "time", "adhanDate", "adhan", "rawDate"] {
            if let value = mirror.descendant(key) as? Date { return value }
        }

        let fmt = DateFormatter()
        fmt.locale = .current
        fmt.timeZone = .current
        fmt.dateFormat = "HH:mm"
        if let text = (mirror.descendant("timeLabel") as? String),
           let t = fmt.date(from: text) {
            return Calendar.current.date(
                bySettingHour: Calendar.current.component(.hour, from: t),
                minute: Calendar.current.component(.minute, from: t),
                second: 0,
                of: Date()
            )
        }
        return nil
    }
}

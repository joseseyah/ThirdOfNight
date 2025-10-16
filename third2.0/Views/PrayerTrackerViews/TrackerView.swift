import SwiftUI
import CoreLocation
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = TrackerViewModel()

    @State private var showAdsSheet = false
    @State private var showLastThirdSheet = false

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

            if let _ = vm.coordinate, !vm.prayers.isEmpty {
                VStack(spacing: sectionSpacing) {
                    VStack(spacing: headingGap) {
                        // Tap to show “Last Third of the Night” sheet
                        Button {
                            showLastThirdSheet = true
                        } label: {
                            LocationHeader(loc: vm.locationManager)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        // Tap to toggle Gregorian ↔︎ Hijri display
                        Text(vm.displayDateString(gregorianTemplate: "EEEE d MMMM",
                                                  hijriTemplate: "d MMMM"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .onTapGesture { vm.toggleDateCalendar() }
                            .animation(.easeInOut(duration: 0.15), value: vm.showingHijri)
                            .accessibilityLabel(vm.showingHijri ? "Hijri date" : "Gregorian date")
                    }

                    // Prayer rows
                    VStack(spacing: rowSpacing) {
                        ForEach(vm.prayers.indices, id: \.self) { i in
                            let item = vm.prayers[i]
                            PrayerRowView(
                                name: item.name,
                                time: item.timeLabel,
                                isDone: item.done,
                                isEnabled: item.canMark()
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                    vm.togglePrayer(at: i)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, sidePadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: verticalNudge)
            } else {
                LocationNotOnView(loc: vm.locationManager)
            }
        }

        // Support (ads) button
        .overlay(alignment: .bottomTrailing) {
            Button {
                showAdsSheet = true
            } label: {
                Image(systemName: "bag")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appBg)
                    .frame(width: 48, height: 48)
                    .background(Color.accentYellow)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                    .overlay(
                        Circle()
                            .stroke(Color.stroke, lineWidth: 1)
                    )
                    .accessibilityLabel("Support us")
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }

        // Ads sheet
        .sheet(isPresented: $showAdsSheet) {
            AdsSheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .background(Color.appBg.ignoresSafeArea())
        }

        // Last Third of the Night sheet
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

        .onAppear {
            vm.configure(context: modelContext)
            vm.onAppear()
        }
        .onDisappear { vm.onDisappear() }
    }
}

// MARK: - Helpers (TrackerView)

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

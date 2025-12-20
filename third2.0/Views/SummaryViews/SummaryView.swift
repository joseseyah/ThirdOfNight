import SwiftUI
import SwiftData
import UIKit

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var today: [PrayerDay]
    @Query private var allDays: [PrayerDay]
    @Query private var missedFasts: [MissedFast]

    @State private var monthPage: Int = 0
    @State private var selectedFilter: AnalyticsFilter = .salah
    @State private var showAddMissedFast = false
    @State private var hasMissedFastsInFirebase: Bool = false
    @State private var isLoadingFirebase: Bool = false

    // Preview + Share state
    @State private var previewImage: UIImage? = nil
    @State private var showPreview = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []   // UIImage / String / URL etc.

    private let sidePadding: CGFloat = 24
    private let gapBelowHeading: CGFloat = 14
    private let chipSpacing: CGFloat = 16
    private let chipHeight: CGFloat = 100

    private let heatmapHeight: CGFloat = 220
    private let dotsAllowance: CGFloat = 16

    init() {
        let key = PrayerDay.key(for: Date())
        _today   = Query(filter: #Predicate<PrayerDay> { $0.dayKey == key }, sort: [])
        _allDays = Query(sort: [])
    }

    private var monthList: [Date] {
        let cal = Calendar.autoupdatingCurrent
        let todayMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!

        let earliest = allDays.map { $0.date }.min() ?? Date()
        var start = cal.date(from: cal.dateComponents([.year, .month], from: earliest)) ?? todayMonth
        if start > todayMonth { start = todayMonth }

        var out: [Date] = []
        var cursor = start
        while cursor <= todayMonth {
            out.append(cursor)
            cursor = cal.date(byAdding: .month, value: 1, to: cursor)!
        }
        return out.isEmpty ? [todayMonth] : out
    }

    private func monthTitle(_ d: Date) -> String {
        let m = DateFormatter(); m.dateFormat = "LLLL"
        let y = DateFormatter(); y.dateFormat = "yy"
        return "\(m.string(from: d)) TRENDS '\(y.string(from: d))"
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // My Journey Title
                    VStack(spacing: 8) {
                        Text("My Journey")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimaryLight)
                        
                        Text("Track your spiritual progress and growth")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.textSecondaryLight)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Filter Buttons
                    HStack(spacing: 12) {
                        ForEach(AnalyticsFilter.allCases, id: \.self) { filter in
                            FilterButton(
                                filter: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, sidePadding)
                    .padding(.bottom, 20)

                    // Content based on selected filter
                    if selectedFilter == .salah {
                        salahAnalyticsContent
                    } else if selectedFilter == .fasting {
                        fastingContent
                            .task {
                                await checkFirebaseForMissedFasts()
                            }
                    } else if selectedFilter == .menstruation {
                        menstruationContent
                    } else if selectedFilter == .umrah {
                        umrahContent
                    }

                    Spacer(minLength: 24)
                }
            }
        }
        // 1) Big in-app preview
        .sheet(isPresented: $showPreview) {
            if let image = previewImage {
                StreakSharePreviewSheet(
                    image: image,
                    onClose: { showPreview = false },
                    onShare: {
                        showPreview = false
                        shareItems = [image]
                        showShareSheet = true
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        // 2) Native Apple share sheet
        .sheet(isPresented: $showShareSheet) {
            ActivityShareSheet(items: shareItems)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Content Views
private extension SummaryView {
    var salahAnalyticsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            let weekDone = SummaryViewModel.weekDoneForCurrentWeek(allDays: allDays)
            
            GeometryReader { geo in
                let columns = 3
                let width = (geo.size.width - chipSpacing * CGFloat(columns - 1)) / CGFloat(columns)

                let todayCount = SummaryViewModel.todayCompletedCount(today: today)
                let (currentStreak, bestStreak) = SummaryViewModel.streaks(allDays: allDays)
                let onTime = SummaryViewModel.onTimeDisplay(allDays: allDays)

                HStack(spacing: chipSpacing) {
                    MetricChip(title: "Today Completed", value: "\(todayCount) / 5")
                        .frame(width: width, height: chipHeight)

                    // Streak chip → Preview → Apple share sheet
                    MetricChip(
                        title: "Streak",
                        value: "\(currentStreak) " + (currentStreak == 1 ? "day" : "days"),
                        subtitle: "Best \(bestStreak)"
                    )
                    .frame(width: width, height: chipHeight)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        generateShareImageAndPreview(
                            currentStreak: currentStreak,
                            bestStreak: bestStreak,
                            weekDone: weekDone
                        )
                    }

                    MetricChip(title: "On-time %", value: onTime)
                        .frame(width: width, height: chipHeight)
                }
            }
            .frame(height: chipHeight)
            .padding(.horizontal, sidePadding)

            SectionHeader("7 DAY TREND")
                .padding(.horizontal, sidePadding)

            TrendWeekCard(weekDone: SummaryViewModel.weekDoneForCurrentWeek(allDays: allDays),
                          highlightIndex: nil)
                .padding(.horizontal, sidePadding)

            if !monthList.isEmpty {
                SectionHeader(monthTitle(monthList[min(monthPage, monthList.count - 1)]))
                    .padding(.horizontal, sidePadding)

                TabView(selection: $monthPage) {
                    ForEach(Array(monthList.enumerated()), id: \.offset) { idx, month in
                        PrayerHeatmapCard(month: month)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: heatmapHeight + dotsAllowance)
                .padding(.horizontal, sidePadding)
                .clipped()
                .onAppear {
                    monthPage = max(0, monthList.count - 1)
                }
            }
        }
    }
    
    var fastingContent: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                AddMissedFastCard {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        showAddMissedFast = true
                    }
                }
                .padding(.horizontal, sidePadding)
                .padding(.top, 20)
                
                // Missed Fasts section header
                SettingsSectionHeader(title: "Missed Fasts")
                    .padding(.horizontal, sidePadding)
                    .padding(.top, 8)
                
                // Show "All caught up" card only if there are no missed fasts in SwiftData AND Firebase
                if missedFasts.isEmpty && !hasMissedFastsInFirebase && !isLoadingFirebase {
                    AllCaughtUpCard()
                        .padding(.horizontal, sidePadding)
                        .padding(.top, 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(showAddMissedFast ? 0 : 1)
            
            if showAddMissedFast {
                AddMissedFastView(isPresented: $showAddMissedFast)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func checkFirebaseForMissedFasts() async {
        isLoadingFirebase = true
        
        do {
            let firebaseMissedFasts = try await MissedFastSyncService.shared.loadAllMissedFasts()
            await MainActor.run {
                hasMissedFastsInFirebase = !firebaseMissedFasts.isEmpty
                isLoadingFirebase = false
            }
        } catch {
            print("⚠️ Failed to check Firebase for missed fasts: \(error.localizedDescription)")
            await MainActor.run {
                // If we can't check Firebase, assume there might be missed fasts to be safe
                hasMissedFastsInFirebase = false
                isLoadingFirebase = false
            }
        }
    }
    
    var menstruationContent: some View {
        VStack(spacing: 24) {
            Text("Menstruation tracking coming soon")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.textSecondaryLight)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity)
    }
    
    var umrahContent: some View {
        VStack(spacing: 24) {
            Text("Umrah tracking coming soon")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.textSecondaryLight)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Share helpers
private extension SummaryView {
    func generateShareImageAndPreview(currentStreak: Int, bestStreak: Int, weekDone: [Bool]) {
        // Duolingo-style card render (hi-res)
        let card = StreakShareCard(
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            weekDone: weekDone
        )
        .frame(width: 1000, height: 1400)
        .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale

        if let img = renderer.uiImage {
            previewImage = img
            showPreview = true
        } else {
            // Fallback: share text if render fails
            shareItems = ["I'm on a \(currentStreak)-day streak in Night Prayers! Best: \(bestStreak). 🌙"]
            showShareSheet = true
        }
    }
}

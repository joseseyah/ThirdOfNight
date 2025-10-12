//
//  TrendWeekViewModel.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/10/2025.
//


// TrendWeekViewModel.swift
import SwiftUI
import Combine

final class TrendWeekViewModel: ObservableObject {
    // Public outputs for the View
    @Published var labels: [String] = ["M","T","W","T","F","S","S"]
    @Published var todayIndex: Int = 0

    // Config
    private let calendar: Calendar
    private var overrideIndex: Int?

    // Midnight detection
    @Published private var dayToken: String
    private var timerCancellable: AnyCancellable?

    // MARK: - Init
    init(overrideIndex: Int? = nil, calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
        self.overrideIndex = overrideIndex
        self.dayToken = Self.dayToken(for: Date(), calendar: calendar)
        self.todayIndex = overrideIndex ?? Self.mondayFirstIndex(for: Date(), calendar: calendar)

        // Tick every 60s; when the date flips, recompute todayIndex
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let token = Self.dayToken(for: Date(), calendar: self.calendar)
                if token != self.dayToken {
                    self.dayToken = token
                    self.recomputeToday()
                }
            }
    }

    deinit {
        timerCancellable?.cancel()
    }

    // MARK: - Public API
    func setOverride(_ index: Int?) {
        overrideIndex = index
        recomputeToday()
    }

    // MARK: - Internal
    private func recomputeToday() {
        todayIndex = overrideIndex ?? Self.mondayFirstIndex(for: Date(), calendar: calendar)
    }

    // MARK: - Helpers (moved from the View)
    /// Monday-first index (0=Mon … 6=Sun). Maps Apple's 1=Sun … 7=Sat.
    static func mondayFirstIndex(for date: Date,
                                 calendar: Calendar = .autoupdatingCurrent) -> Int {
        let wd = calendar.component(.weekday, from: date) // 1=Sun … 7=Sat
        return (wd + 5) % 7                                // 0=Mon … 6=Sun
    }

    /// Token that changes once per day to detect midnight rollover.
    static func dayToken(for date: Date,
                         calendar: Calendar = .autoupdatingCurrent) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }
}

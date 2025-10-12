// TrendWeekCard.swift
import SwiftUI

struct TrendWeekCard: View {
    let weekDone: [Bool]

    // Inject optional override (0 = Mon … 6 = Sun)
    @StateObject private var vm: TrendWeekViewModel

    init(weekDone: [Bool], highlightIndex: Int? = nil) {
        self.weekDone = weekDone
        _vm = StateObject(wrappedValue: TrendWeekViewModel(overrideIndex: highlightIndex))
    }

    var body: some View {
        CardContainer {
            HStack(spacing: 14) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 8) {
                        ZStack {
                            // Background plate
                            Circle().fill(Color.white.opacity(0.06))

                            // Optional fill if that day is done
                            if weekDone.indices.contains(i), weekDone[i] {
                                Circle().fill(Color.accentYellow.opacity(0.95)).padding(8)
                            }

                            // Rim for "today"
                            if i == vm.todayIndex {
                                Circle().stroke(Color.accentYellow.opacity(0.9), lineWidth: 2)
                            }
                        }
                        .frame(width: 38, height: 38)

                        Text(vm.labels[i])
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(i == vm.todayIndex ? .textPrimary : .textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

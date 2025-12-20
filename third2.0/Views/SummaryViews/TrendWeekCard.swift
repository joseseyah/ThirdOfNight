// TrendWeekCard.swift
import SwiftUI

struct TrendWeekCard: View {
    let weekDone: [Bool]

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

                            if weekDone.indices.contains(i), weekDone[i] {
                                Circle().fill(Color.accentPurple.opacity(0.95)).padding(8)
                            }

                            // Rim for "today"
                            if i == vm.todayIndex {
                                Circle().stroke(Color.accentPurple.opacity(0.9), lineWidth: 2)
                            }
                        }
                        .frame(width: 38, height: 38)

                        Text(vm.labels[i])
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(i == vm.todayIndex ? .accentPurple : .textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

import SwiftUI
import SwiftData

struct PrayerHeatmapCard: View {
    @Query private var allDays: [PrayerDay]
    private let vm: PrayerHeatmapViewModel

    // Layout knobs (UI only)
    private let labelWidth: CGFloat = 64
    private let cellSize: CGFloat   = 12
    private let rowSpacing: CGFloat = 8
    private let colSpacing: CGFloat = 5
    private let weekGap: CGFloat    = 12   // visual gap between weeks

    init(month: Date = Date()) {
        self.vm = PrayerHeatmapViewModel(month: month)
        _allDays = Query(sort: [])
    }

    var body: some View {
        let data = vm.preparedData(allDays: allDays)

        CardContainer {
            HStack(alignment: .top, spacing: 12) {
                // Left labels (prayer names)
                VStack(alignment: .leading, spacing: rowSpacing) {
                    // space for the top day-number axis
                    Spacer().frame(height: cellSize)

                    ForEach(0..<vm.prayers.count, id: \.self) { r in
                        Text(vm.prayers[r])
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .frame(width: labelWidth, height: cellSize, alignment: .leading)
                    }
                }

                // Grid + TOP column labels
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: rowSpacing) {

                        // DAY NUMBER AXIS (TOP)
                        HStack(spacing: colSpacing) {
                            ForEach(0..<data.daysInMonth, id: \.self) { c in
                                Text(data.dayLabels[c])
                                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundColor(.textSecondary.opacity(0.85))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .frame(width: cellSize, height: cellSize, alignment: .center)

                                if data.weekGapAfter[c] {
                                    Color.clear.frame(width: weekGap, height: 1)
                                }
                            }
                        }
                        .padding(.bottom, 2)

                        // PRAYER ROWS
                        ForEach(0..<vm.prayers.count, id: \.self) { r in
                            HStack(spacing: colSpacing) {
                                ForEach(0..<data.daysInMonth, id: \.self) { c in
                                    let isOn = data.matrix[r][c]

                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(isOn ? Color.accentYellow : Color.white.opacity(0.10))
                                        .frame(width: cellSize, height: cellSize)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                                .stroke(
                                                    isOn ? Color.accentYellow.opacity(0.55) : Color.stroke,
                                                    lineWidth: isOn ? 0.5 : 0.8
                                                )
                                        )

                                    if data.weekGapAfter[c] {
                                        Color.clear.frame(width: weekGap, height: 1)
                                    }
                                }
                            }
                            .frame(height: cellSize, alignment: .leading)
                        }
                    }
                    .padding(.trailing, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.vertical, 0)
        }
        .padding(.vertical, 0)
    }
}

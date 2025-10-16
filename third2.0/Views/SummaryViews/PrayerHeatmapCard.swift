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
    private let weekGapSize: CGFloat = 6
    private let showWeekGaps: Bool = true

    init(month: Date = Date()) {
        self.vm = PrayerHeatmapViewModel(month: month)
        _allDays = Query(sort: [])
    }

    var body: some View {
        let matrix = vm.buildMatrix(allDays: allDays)
        let daysInMonth = vm.daysInMonth

        CardContainer {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(0..<vm.prayers.count, id: \.self) { r in
                        Text(vm.prayers[r])
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .frame(width: labelWidth, height: cellSize, alignment: .leading)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: rowSpacing) {
                        ForEach(0..<vm.prayers.count, id: \.self) { r in
                            HStack(spacing: colSpacing) {
                                ForEach(0..<daysInMonth, id: \.self) { c in
                                    let isOn = matrix[r][c]
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(isOn ? Color.accentYellow : Color.white.opacity(0.10))
                                        .frame(width: cellSize, height: cellSize)
                                        .shadow(color: isOn ? Color.accentYellow.opacity(0.25) : .clear,
                                                radius: isOn ? 4 : 0)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                                .stroke(isOn ? Color.accentYellow.opacity(0.55) : Color.stroke,
                                                        lineWidth: isOn ? 0.5 : 0.8)
                                        )
                                }
                            }
                            .frame(height: cellSize, alignment: .leading)
                        }
                    }
                    .padding(.trailing, 2)
                }
            }
        }
    }
}

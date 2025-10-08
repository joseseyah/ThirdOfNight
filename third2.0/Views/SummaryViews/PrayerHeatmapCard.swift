import SwiftUI

struct PrayerHeatmapCard: View {
    let matrix: [[Bool]] // 5 x N
    private let prayers = ["FAJR","DHUHR","ASR","MAGHRIB","ISHA"]

    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(prayers, id: \.self) { p in
                        Text(p)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .frame(height: 14, alignment: .center)
                    }
                }
                .frame(width: 64, alignment: .leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(matrix.indices, id: \.self) { r in
                            HStack(spacing: 5) {
                                ForEach(matrix[r].indices, id: \.self) { c in
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(matrix[r][c] ? Color.accentYellow : Color.white.opacity(0.10))
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                    }
                    .padding(.trailing, 2)
                }
            }
        }
    }

    static func sampleMatrix(cols: Int) -> [[Bool]] {
        let rows = 5
        return (0..<rows).map { r in
            (0..<cols).map { c in ((r * 3 + c) % 4) != 0 }
        }
    }
}

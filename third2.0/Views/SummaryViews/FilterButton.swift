import SwiftUI

enum AnalyticsFilter: String, CaseIterable {
    case salah = "Salah"
    case fasting = "Fasting"
    case menstruation = "Menstruation"
    case umrah = "Umrah"
    
    var icon: String {
        switch self {
        case .salah:
            return "moon.fill"
        case .fasting:
            return "sun.max.fill"
        case .menstruation:
            return "snowflake"
        case .umrah:
            return "building.2.fill"
        }
    }
}

struct FilterButton: View {
    let filter: AnalyticsFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .buttonText : .textPrimaryLight)
                
                Text(filter.rawValue)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .buttonText : .textPrimaryLight)
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.accentPurple : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.accentPurple.opacity(0.6) : Color.white.opacity(0.25), lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(color: isSelected ? Color.accentPurple.opacity(0.3) : Color.black.opacity(0.15), radius: isSelected ? 6 : 3, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}


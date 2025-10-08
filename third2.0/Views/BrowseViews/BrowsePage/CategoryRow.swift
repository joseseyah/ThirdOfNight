//
//  CategoryRow.swift
//  Night Prayers
//

import SwiftUI

struct CategoryRow: View {
    let item: BrowseCategory

    var body: some View {
        NavigationLink {
            RemindersView(category: item)
        } label: {
            HStack(spacing: 12) {
                // Icon chip (small)
                ZStack {
                    Circle().fill(Color.white.opacity(0.06))
                    Image(systemName: item.systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appBg)
                        .padding(8)
                        .background(Circle().fill(item.tint))
                }
                .frame(width: 44, height: 44)

                Text(item.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.clear) // keep tap target shape consistent
            )
            .contentShape(Rectangle())
        }
    }
}

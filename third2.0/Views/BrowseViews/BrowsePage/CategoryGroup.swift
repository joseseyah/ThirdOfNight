//
//  CategoryGroup.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//

import SwiftUI

struct CategoryGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.stroke, lineWidth: 1)
                )
        )
    }
}

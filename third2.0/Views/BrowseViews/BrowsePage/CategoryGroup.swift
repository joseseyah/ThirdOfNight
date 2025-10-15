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
        // Stacked cards with comfortable rhythm—matches the modern list look
        VStack(spacing: 14) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

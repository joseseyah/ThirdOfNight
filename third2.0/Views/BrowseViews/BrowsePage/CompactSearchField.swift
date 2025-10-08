//
//  CompactSearchField.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import SwiftUI

struct CompactSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            TextField("Search", text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.stroke, lineWidth: 1)
                )
        )
    }
}

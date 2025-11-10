//
//  DividerLine.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 10/11/2025.
//
import SwiftUI

struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .overlay(Rectangle().fill(Color.black.opacity(0.08)).frame(height: 0.5))
            .padding(.horizontal, 12)
    }
}

//
//  CombineGroupOutline.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 10/11/2025.
//
import SwiftUI

struct CombineGroupOutline<Content: View>: View {
    @ViewBuilder var content: Content
    private let corner: CGFloat = 14

    var body: some View {
        VStack(spacing: 0) { content }
            .background(
                RoundedRectangle(cornerRadius: corner)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner)
                    .stroke(Color.stroke, lineWidth: 1.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: corner))
    }
}

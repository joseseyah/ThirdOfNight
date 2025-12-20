//
//  TasbihCircleButton.swift
//  Night Prayers
//
//  Created for Tasbih counter navigation
//
import SwiftUI

struct TasbihCircleButton: View {
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.accentPurple.opacity(0.2))

                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentPurple)
            }
            .frame(width: 38, height: 38)
            .overlay(
                Circle().stroke(Color.accentPurple.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(color: Color.accentPurple.opacity(0.3), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            .contentShape(Circle())
        }
        .buttonStyle(CirclePressStyle())
        .accessibilityLabel("Tasbih counter")
        .accessibilityAddTraits(.isButton)
    }
}


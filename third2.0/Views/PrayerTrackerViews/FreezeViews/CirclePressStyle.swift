//
//  CirclePressStyle.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 16/10/2025.
//
import SwiftUI

struct CirclePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .overlay(
                Circle()
                    .stroke(Color.accentYellow.opacity(configuration.isPressed ? 0.35 : 0), lineWidth: 2)
            )
            .shadow(color: Color.accentYellow.opacity(configuration.isPressed ? 0.22 : 0), radius: 12)
            .opacity(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

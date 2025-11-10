//
//  TravelGroupPressStyle.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 10/11/2025.
//
import SwiftUI

struct TravelGroupPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.accentYellow.opacity(configuration.isPressed ? 0.35 : 0), lineWidth: 2)
            )
            .shadow(color: Color.accentYellow.opacity(configuration.isPressed ? 0.22 : 0), radius: 14)
            .opacity(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

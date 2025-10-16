//
//  FreezeCircleButton.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 16/10/2025.
//
import SwiftUI

struct FreezeCircleButton: View {
    @Binding var isOn: Bool
    var onActivate: (() -> Void)? = nil
    var onDeactivate: (() -> Void)? = nil

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
                isOn.toggle()
                if isOn { onActivate?() } else { onDeactivate?() }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(isOn ? Color.accentYellow : Color.white.opacity(0.06))

                Image(systemName: "snowflake")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isOn ? .appBg : .textPrimary)

                if isOn {
                    Circle()
                        .fill(Color.accentYellow.opacity(0.18))
                        .frame(width: 42, height: 42)
                        .blur(radius: 18)
                        .blendMode(.plusLighter)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: 38, height: 38)
            .overlay(
                Circle().stroke(isOn ? Color.accentYellow.opacity(0.65) : Color.stroke, lineWidth: 1)
            )
            .shadow(color: isOn ? Color.accentYellow.opacity(0.24) : .clear, radius: 14, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)
            .contentShape(Circle())
        }
        .buttonStyle(CirclePressStyle())
        .accessibilityLabel(isOn ? "Freeze active" : "Freeze inactive")
        .accessibilityAddTraits(.isButton)
    }
}

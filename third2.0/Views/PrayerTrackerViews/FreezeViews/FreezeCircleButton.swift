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
                    .fill(isOn ? Color.accentPurple : Color.accentPurple.opacity(0.2))

                Image(systemName: "snowflake")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isOn ? .buttonText : .accentPurple)

                if isOn {
                    Circle()
                        .fill(Color.accentPurple.opacity(0.3))
                        .frame(width: 42, height: 42)
                        .blur(radius: 18)
                        .blendMode(.plusLighter)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: 38, height: 38)
            .overlay(
                Circle().stroke(isOn ? Color.accentPurple.opacity(0.8) : Color.accentPurple.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(color: isOn ? Color.accentPurple.opacity(0.4) : Color.accentPurple.opacity(0.2), radius: 12, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            .contentShape(Circle())
        }
        .buttonStyle(CirclePressStyle())
        .accessibilityLabel(isOn ? "Freeze active" : "Freeze inactive")
        .accessibilityAddTraits(.isButton)
    }
}

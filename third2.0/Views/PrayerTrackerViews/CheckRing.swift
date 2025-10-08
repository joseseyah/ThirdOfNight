//
//  CheckRing.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 06/10/2025.
//
import SwiftUI

struct CheckRing: View {
    let isOn: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.stroke, lineWidth: 2)
                .frame(width: 28, height: 28)

            Circle()
                .trim(from: 0, to: isOn ? 1 : 0)
                .stroke(Color.accentYellow, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 28, height: 28)
                .animation(.easeInOut(duration: 0.18), value: isOn)

            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.appBg)
                    .padding(6)
                    .background(Circle().fill(Color.accentYellow))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 32, height: 32)
    }
}

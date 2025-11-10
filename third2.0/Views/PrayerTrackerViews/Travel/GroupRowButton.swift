//
//  GroupRowButton.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 10/11/2025.
//
import SwiftUI

struct GroupRowButton: View {
    let item: TravelRowItem

    private var nameColor: Color { item.isDone ? .accentYellow : .textPrimary }
    private var timeTextColor: Color { item.isDone ? .appBg : .textPrimary }
    private var timeFill: Color { item.isDone ? .accentYellow : Color.white.opacity(0.05) }
    private var timeStroke: Color { item.isDone ? Color.accentYellow.opacity(0.85) : .stroke }

    var body: some View {
        Button(action: item.onTap) {
            HStack(spacing: 12) {
                ZStack {
                    CompactCheckRing(isOn: item.isDone)

                    if item.isDone {
                        Circle()
                            .fill(Color.accentYellow.opacity(0.18))
                            .frame(width: 42, height: 42)
                            .blur(radius: 18)
                            .blendMode(.plusLighter)
                            .allowsHitTesting(false)
                    }
                }

                Text(item.display.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(nameColor)
                    .shadow(color: item.isDone ? Color.accentYellow.opacity(0.25) : .clear,
                            radius: item.isDone ? 6 : 0, x: 0, y: 0)

                Spacer(minLength: 8)

                Text(item.display.timeText)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(timeTextColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        ZStack {
                            Capsule().fill(timeFill)
                            Capsule().stroke(timeStroke, lineWidth: 1.2)

                            if item.isDone {
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 0.6)
                                    .blur(radius: 0.6)
                                    .opacity(0.65)
                            }
                            if item.isDone {
                                Capsule()
                                    .fill(Color.accentYellow.opacity(0.22))
                                    .blur(radius: 16)
                                    .blendMode(.plusLighter)
                            }
                        }
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(item.isEnabled ? 1 : 0.55)
            .animation(.spring(response: 0.22, dampingFraction: 0.9), value: item.isDone)
        }
        .buttonStyle(TravelGroupPressStyle())
        .disabled(!item.isEnabled)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.clear)
        )
    }
}

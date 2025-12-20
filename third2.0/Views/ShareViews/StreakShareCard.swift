//
//  StreakShareCard.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 17/10/2025.
//


import SwiftUI
import UIKit

// 1) The card we render to an image for sharing
public struct StreakShareCard: View {
    let currentStreak: Int
    let bestStreak: Int
    let weekDone: [Bool] // Monday → Sunday

    private let labels = ["M","T","W","T","F","S","S"]
    private static let mondayFirstWeekdayNumbers = [2,3,4,5,6,7,1]
    private static func todayIndex() -> Int {
        let todayNum = Calendar.autoupdatingCurrent.component(.weekday, from: Date()) // Sun=1...Sat=7
        return mondayFirstWeekdayNumbers.firstIndex(of: todayNum) ?? 0
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.19),
                    Color(red: 0.06, green: 0.07, blue: 0.12)
                ]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            VStack(spacing: 22) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .imageScale(.large)
                        .foregroundColor(.accentMoon)
                    Text("Third of the Night")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    Spacer()
                }

                VStack(spacing: 6) {
                    Text("\(currentStreak)")
                        .font(.system(size: 110, weight: .heavy, design: .rounded))
                        .foregroundColor(.textPrimary)
                    Text("praying on time")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 6)

                HStack(spacing: 8) {
                    Image(systemName: "flame.fill").foregroundColor(.accentMoon)
                    Text("Best \(bestStreak)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.10)))

                // Week dots
                let today = Self.todayIndex()
                HStack(spacing: 18) {
                    ForEach(labels.indices, id: \.self) { i in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.12))
                                if weekDone.indices.contains(i), weekDone[i] {
                                    Circle().fill(Color.accentMoon.opacity(0.95)).padding(10)
                                }
                                if i == today {
                                    Circle().stroke(Color.accentMoon.opacity(0.85), lineWidth: 3)
                                }
                            }
                            .frame(width: 72, height: 72)
                            Text(labels[i])
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(.top, 8)

                VStack(spacing: 8) {
                    Text("Keep going! May Allah accept all of our good deeds 🌙")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    Text("Track, reflect, and stay consistent.")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, 12)
            }
            .padding(28)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

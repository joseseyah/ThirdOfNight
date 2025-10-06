//
//  TrackerView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 06/10/2025.
//
import Foundation
import SwiftUI

struct TrackerView: View {
  @State private var prayers: [PrayerItem] = [
    .init(name: "Fajr",    time: "05:35"),
    .init(name: "Dhuhr",   time: "12:53"),
    .init(name: "Asr",     time: "15:46"),
    .init(name: "Maghrib", time: "18:29"),
    .init(name: "Isha",    time: "19:46")
  ]

  var body: some View {
    ZStack {
      Color.appBg.ignoresSafeArea()

      VStack(spacing: 18) {
        VStack(spacing: 10) {
          Text("Prayer Times")
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundColor(.accentYellow)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.white.opacity(0.06)))

          Text(dateString("EEEE d MMMM"))
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundColor(.textPrimary)
        }
        VStack(spacing: 14) {
          ForEach(prayers.indices, id: \.self) { i in
            PrayerRowView(
              name: prayers[i].name,
              time: prayers[i].time,
              isDone: prayers[i].done
            ) {
              withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                prayers[i].done.toggle()
                simpleHaptic()
              }
            }
          }
        }
        .padding(.horizontal, 16)

        Spacer(minLength: 0)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  private func dateString(_ format: String) -> String {
    let f = DateFormatter()
    f.locale = .current
    f.dateFormat = format
    return f.string(from: Date())
  }

  private func simpleHaptic() {
#if os(iOS)
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
  }


}

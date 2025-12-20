import SwiftUI
import UIKit

struct ShareStreakPayload: Equatable {
    let currentStreak: Int
    let bestStreak: Int
    let weekDone: [Bool]   // Monday → Sunday
}

struct ShareStreakView: View {
    let payload: ShareStreakPayload
    @Environment(\.dismiss) private var dismiss

    @State private var shareImage: UIImage? = nil
    @State private var showSystemShare = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                // The thing we’ll render to an image
                ShareCard(payload: payload)
                    .background(
                        // Rounded, glowing card background
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.cardBg)
                            .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 16)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 18)
                    .padding(.top, 8)

                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                    }

                    Button {
                        exportAndShare()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentMoon.opacity(0.2)))
                    }
                }
                .foregroundColor(.textPrimary)
                .padding(.bottom, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea())
            .navigationTitle("Share your streak")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showSystemShare) {
            if let image = shareImage {
                ActivityShareSheet(items: [image])
                    .ignoresSafeArea()
            }
        }
    }

    private func exportAndShare() {
        // Render ShareCard to an image using ImageRenderer (iOS 16+)
        let card = ShareCard(payload: payload)
            .frame(width: 1000, height: 1400) // high-res export for socials

        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            self.shareImage = uiImage
            self.showSystemShare = true
        }
    }
}

private struct ShareCard: View {
    let payload: ShareStreakPayload

    // Visual knobs
    private let corner: CGFloat = 28

    var body: some View {
        ZStack {
            // Gradient/moon-ish backdrop
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.19),
                    Color(red: 0.06, green: 0.07, blue: 0.12)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 22) {
                // App / header
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .imageScale(.large)
                        .foregroundColor(.accentMoon)
                    Text("Night Prayers")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundColor(.textPrimary)

                // Big streak number
                VStack(spacing: 6) {
                    Text("\(payload.currentStreak)")
                        .font(.system(size: 96, weight: .heavy, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .minimumScaleFactor(0.6)
                    Text(payload.currentStreak == 1 ? "day streak" : "day streak")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 6)

                // Best streak badge
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.accentMoon)
                    Text("Best \(payload.bestStreak)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))

                // Week dots (Mon → Sun), highlight today
                WeekDots(weekDone: payload.weekDone)

                Spacer()

                // Footer CTA / watermark
                VStack(spacing: 8) {
                    Text("Keep the moonlight streak going 🌙")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)

                    Text("Track, reflect, and stay consistent.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, 10)
            }
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}

private struct WeekDots: View {
    let weekDone: [Bool] // Monday → Sunday

    private let labels = ["M","T","W","T","F","S","S"]

    private static let mondayFirstWeekdayNumbers = [2,3,4,5,6,7,1]
    private static func todayIndex() -> Int {
        let todayNum = Calendar.autoupdatingCurrent.component(.weekday, from: Date()) // Sun=1...Sat=7
        return mondayFirstWeekdayNumbers.firstIndex(of: todayNum) ?? 0
    }

    var body: some View {
        let today = Self.todayIndex()

        HStack(spacing: 16) {
            ForEach(labels.indices, id: \.self) { i in
                VStack(spacing: 8) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.10))
                        if weekDone.indices.contains(i), weekDone[i] {
                            Circle().fill(Color.accentMoon.opacity(0.9))
                                .padding(8)
                        }
                        if i == today {
                            Circle().stroke(Color.accentMoon.opacity(0.8), lineWidth: 2)
                        }
                    }
                    .frame(width: 56, height: 56)

                    Text(labels[i])
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.top, 8)
    }
}

// UIKit share sheet wrapper
struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var activities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: activities)
        vc.excludedActivityTypes = [.assignToContact, .addToReadingList, .openInIBooks]
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

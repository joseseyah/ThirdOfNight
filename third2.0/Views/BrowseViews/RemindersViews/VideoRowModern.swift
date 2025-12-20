//
//  VideoRowModern.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 13/10/2025.
//


import SwiftUI

struct VideoRowModern: View {
    let video: PlaylistVideo
    var corner: CGFloat = 18
    private let thumbSide: CGFloat = 92
    @State private var pressed = false

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            AsyncImage(url: video.thumbnailURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .empty: ZStack { Color.cardBg.opacity(0.6); ProgressView().scaleEffect(0.8) }
                case .failure(_): ZStack { Color.cardBg; Image(systemName: "play.rectangle.fill").font(.system(size: 22, weight: .medium)).opacity(0.35) }
                @unknown default: Color.cardBg
                }
            }
            .frame(width: thumbSide, height: thumbSide)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))

            // Text
            VStack(alignment: .leading, spacing: 8) {
                Text(video.title)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Pill(text: video.channel)
                }
            }
            .layoutPriority(1) // text can grow, but not at pill’s expense
            .frame(maxWidth: .infinity, alignment: .leading)

            // WATCH pill – non-compressible
            WatchPill()
                .fixedSize(horizontal: true, vertical: false) // <— keep intrinsic width
                .layoutPriority(2)                             // <— resist compression
                .frame(minHeight: 36)                          // optional
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: corner + 6, style: .continuous).fill(Color.cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: corner + 6, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(pressed ? 0.10 : 0.16), radius: pressed ? 6 : 12, x: 0, y: pressed ? 3 : 6)
        .scaleEffect(pressed ? 0.98 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: pressed)
        .contentShape(RoundedRectangle(cornerRadius: corner + 6, style: .continuous))
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in
            if !pressed { pressed = true }
        }.onEnded { _ in
            pressed = false
        })
    }
}

// Compact, non-wrapping pill
private struct WatchPill: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "play.fill")
                .font(.system(size: 12, weight: .bold))
            Text("Watch")
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1) // don’t wrap
                .allowsTightening(true)
                .minimumScaleFactor(0.95)
        }
        .foregroundColor(.black)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Capsule(style: .continuous).fill(Color.accentMoon))
    }
}

// Reusable pill
private struct Pill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12.5, weight: .semibold))
            .foregroundColor(.textPrimary.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

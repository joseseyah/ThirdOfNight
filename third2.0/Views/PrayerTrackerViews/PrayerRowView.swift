import SwiftUI

struct PrayerRowView: View {
    let name: String
    let time: String
    let isDone: Bool
    let isEnabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // CHECK RING + GLOW
                ZStack {
                    CompactCheckRing(isOn: isDone)
                    // soft halo when done
                    if isDone {
                        Circle()
                            .fill(Color.accentYellow.opacity(0.18))
                            .frame(width: 42, height: 42)
                            .blur(radius: 18)
                            .blendMode(.plusLighter)
                            .allowsHitTesting(false)
                    }
                }

                Text(name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Spacer(minLength: 8)

                // TIME PILL WITH INNER/OUTER GLOW
                Text(time)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                            Capsule()
                                .stroke(Color.stroke, lineWidth: 1)

                            // subtle inner rim
                            Capsule()
                                .stroke(Color.accentYellow.opacity(0.28), lineWidth: 1.2)
                                .blur(radius: 1.5)
                                .opacity(isDone ? 1 : 0)

                            // outer bloom when done
                            if isDone {
                                Capsule()
                                    .fill(Color.accentYellow.opacity(0.14))
                                    .blur(radius: 14)
                                    .blendMode(.plusLighter)
                            }
                        }
                    )
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                ZStack {
                    // base card
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.cardBg, Color.cardBg.opacity(0.92)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )

                    // warm vignette/halo when completed
                    if isDone {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.accentYellow.opacity(0.16),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 6, endRadius: 160
                                )
                            )
                            .blendMode(.plusLighter)
                    }

                    // border: accent when done, normal otherwise
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isDone ? Color.accentYellow.opacity(0.65) : Color.stroke, lineWidth: 1)
                }
            )
            // soft drop + light bloom
            .shadow(color: (isDone ? Color.accentYellow.opacity(0.24) : .clear), radius: 14, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)

            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .animation(.spring(response: 0.22, dampingFraction: 0.9), value: isDone)
            .opacity(isEnabled ? 1 : 0.55)
            .compositingGroup() // helps blendMode blooms look smooth
        }
        .buttonStyle(CompactPressStyle())
        .disabled(!isEnabled)
    }
}

private struct CompactPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            // press ring + momentary glow
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.accentYellow.opacity(configuration.isPressed ? 0.35 : 0), lineWidth: 2)
            )
            .shadow(color: Color.accentYellow.opacity(configuration.isPressed ? 0.22 : 0), radius: 14)
            .opacity(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

import SwiftUI

struct PrayerRowView: View {
    let name: String
    let time: String
    let isDone: Bool
    let isEnabled: Bool
    let onTap: () -> Void

    private var nameColor: Color { isDone ? .accentYellow : .textPrimary }
    private var timeTextColor: Color { isDone ? .appBg : .textPrimary }
    private var timeFill: Color { isDone ? .accentYellow : Color.white.opacity(0.05) }
    private var timeStroke: Color { isDone ? Color.accentYellow.opacity(0.85) : .stroke }
    private var cardStroke: Color { isDone ? Color.accentYellow.opacity(0.75) : .stroke }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    CompactCheckRing(isOn: isDone)

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
                    .foregroundColor(nameColor)
                    .shadow(color: isDone ? Color.accentYellow.opacity(0.25) : .clear,
                            radius: isDone ? 6 : 0, x: 0, y: 0)

                Spacer(minLength: 8)

                Text(time)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(timeTextColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        ZStack {
                            Capsule().fill(timeFill)

                            Capsule()
                                .stroke(timeStroke, lineWidth: 1.2)

                            if isDone {
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 0.6)
                                    .blur(radius: 0.6)
                                    .opacity(0.65)
                            }

                            if isDone {
                                Capsule()
                                    .fill(Color.accentYellow.opacity(0.22))
                                    .blur(radius: 16)
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

                    if isDone {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                RadialGradient(
                                    colors: [Color.accentYellow.opacity(0.18), .clear],
                                    center: .center,
                                    startRadius: 6, endRadius: 180
                                )
                            )
                            .blendMode(.plusLighter)
                    }

                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(cardStroke, lineWidth: 1.1)
                }
            )
            .shadow(color: (isDone ? Color.accentYellow.opacity(0.26) : .clear), radius: 14, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)

            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .animation(.spring(response: 0.22, dampingFraction: 0.9), value: isDone)
            .opacity(isEnabled ? 1 : 0.55)
            .compositingGroup()
        }
        .buttonStyle(CompactPressStyle())
        .disabled(!isEnabled)
    }
}

private struct CompactPressStyle: ButtonStyle {
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

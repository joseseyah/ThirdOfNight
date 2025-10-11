import SwiftUI
import CoreLocation

struct QiblaView: View {
    @StateObject private var viewModel = QiblaDistanceManager()

    // Assets
    private let compassAssetName = "Compass"
    private let pointerAssetName = "Pointer"

    // Pointer rotation (degrees)
    @State private var pointerAngle: Double = 0

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            StarOverlay(count: 38, maxYFraction: 0.7, opacity: 0.40)

            GeometryReader { geo in
                VStack(spacing: 16) {
                    Spacer(minLength: geo.size.height * 0.08)

                    // Centered compass (no card)
                    CompassWidget(
                        faceAsset: compassAssetName,
                        pointerAsset: pointerAssetName,
                        size: 300,
                        pointerAngleDegrees: pointerAngle,
                        pointerTint: .accentYellow,
                        pointerScale: 0.25
                    )
                    .frame(maxWidth: .infinity)

                    // Distance card — smaller and near the compass
                    Group {
                        if let distance = viewModel.distanceToQibla {
                            let miles = String(format: "%.1f", distance)
                            VStack(spacing: 6) {
                                Text("\(miles) miles")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.accentYellow)

                                Text("to the Qibla from your current location")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 14)
                            .frame(maxWidth: 420)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.cardBg)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                            .padding(.top, 6)
                            .padding(.horizontal, 20)
                        } else {
                            Text("Calculating distance…")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .frame(maxWidth: 420)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.cardBg)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.stroke, lineWidth: 1)
                                )
                                .padding(.top, 6)
                                .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: geo.size.height * 0.12)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .padding(.bottom, geo.safeAreaInsets.bottom + 6)
            }
        }
        .onAppear {
            viewModel.requestAuthorizationAndInitManager()
            // pointerAngle = viewModel.qiblaBearingDegrees
        }
        .onDisappear {
            viewModel.stopUpdatingLocation()
        }
    }
}

// MARK: - Compass (SVG face + SVG pointer) — no background card
private struct CompassWidget: View {
    let faceAsset: String
    let pointerAsset: String
    let size: CGFloat
    let pointerAngleDegrees: Double
    var pointerTint: Color = .accentYellow
    var pointerScale: CGFloat = 0.44

    var body: some View {
        ZStack {
            Image(faceAsset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            Image(pointerAsset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(pointerTint)
                .frame(width: size * pointerScale, height: size * pointerScale)
                .rotationEffect(.degrees(pointerAngleDegrees))
                .animation(.spring(response: 0.28, dampingFraction: 0.85), value: pointerAngleDegrees)
                .allowsHitTesting(false)
        }
        .accessibilityHidden(true)
    }
}

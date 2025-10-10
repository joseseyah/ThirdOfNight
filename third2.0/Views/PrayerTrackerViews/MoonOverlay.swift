import SwiftUI

/// Crescent moon with a *small, controllable* glow placed inside the safe area.
struct MoonOverlay: View {
    var assetName: String = "moon"   // your SVG name
    var size: CGFloat = 72           // icon size
    var top: CGFloat = 6             // distance from safe-area top
    var leading: CGFloat = 8         // distance from safe-area leading
    var opacity: Double = 0.22       // icon opacity (and base for glow)

    /// Tunables for the glow
    var glowScale: CGFloat = 1.6     // circle size relative to `size` (smaller number = smaller glow)
    var glowBlur: CGFloat = 0.6      // blur relative to `size` (0.6 ≈ subtle, 1.2 ≈ soft)
    var glowOpacity: Double = 0.55   // glow alpha multiplier

    var body: some View {
        GeometryReader { geo in
            // Anchor point inside the notch/safe area
            let x = geo.safeAreaInsets.leading + leading + size / 2
            let y = geo.safeAreaInsets.top     + top     + size / 2

            ZStack {
                // Small, controlled glow (no banding)
                Circle()
                    .fill(Color.accentYellow.opacity(opacity * glowOpacity))
                    .frame(width: size * glowScale * 2, height: size * glowScale * 2)
                    .blur(radius: size * glowBlur)
                    .position(x: x, y: y)
                    .blendMode(.screen) // limit screen blend to the glow only

                // The crescent
                Image(assetName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundStyle(Color.accentYellow)
                    .opacity(opacity)
                    .position(x: x, y: y)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

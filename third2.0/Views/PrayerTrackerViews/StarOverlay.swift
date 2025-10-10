import SwiftUI

/// Subtle star field for dark UIs.
/// Place it behind your content in a ZStack.
struct StarOverlay: View {
    var count: Int = 50                 // number of stars
    var maxYFraction: CGFloat = 0.50    // how far down they appear
    var opacity: Double = 0.5          // overall brightness

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height * maxYFraction

            Canvas { ctx, _ in
                let points = starPoints(in: CGSize(width: w, height: h), count: count)

                for (i, p) in points.enumerated() {
                    let x = p.x, y = p.y
                    let r = p.r        // base size

                    // 1) tiny bright core
                    let core = CGRect(x: x - r/2, y: y - r/2, width: r, height: r)
                    ctx.fill(Path(ellipseIn: core), with: .color(.white.opacity(opacity)))

                    // 2) soft mini glow
                    let glowR = r * 4.0
                    let glow = CGRect(x: x - glowR/2, y: y - glowR/2, width: glowR, height: glowR)
                    ctx.fill(Path(ellipseIn: glow), with: .color(.white.opacity(opacity * 0.25)))

                    // 3) sparkle rays (some stars only)
                    //    use rounded line caps so it feels like a sparkle
                    if i % 3 != 0 { // ~2/3 of stars twinkle
                        let len  = r * 3.2
                        let w1   = max(0.8, r * 0.35)

                        var cross = Path()
                        cross.move(to: CGPoint(x: x, y: y - len))
                        cross.addLine(to: CGPoint(x: x, y: y + len))
                        cross.move(to: CGPoint(x: x - len, y: y))
                        cross.addLine(to: CGPoint(x: x + len, y: y))

                        ctx.stroke(
                            cross,
                            with: .color(.white.opacity(opacity * 0.65)),
                            style: StrokeStyle(lineWidth: w1, lineCap: .round)
                        )

                        // softer diagonal rays for a few — keeps variety
                        if i % 5 == 0 {
                            let dlen = len * 0.72
                            let w2   = w1 * 0.75

                            var diag = Path()
                            diag.move(to: CGPoint(x: x - dlen, y: y - dlen))
                            diag.addLine(to: CGPoint(x: x + dlen, y: y + dlen))
                            diag.move(to: CGPoint(x: x - dlen, y: y + dlen))
                            diag.addLine(to: CGPoint(x: x + dlen, y: y - dlen))

                            ctx.stroke(
                                diag,
                                with: .color(.white.opacity(opacity * 0.40)),
                                style: StrokeStyle(lineWidth: w2, lineCap: .round)
                            )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .blendMode(.screen)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Deterministic positions so stars don't jump
private func starPoints(in size: CGSize, count: Int) -> [StarPoint] {
    // Base positions on a 430×90 "design canvas" so they scale to any width.
    let base: [StarPoint] = [
        .init(12, 18, 2.0),  .init(48, 42, 1.4),  .init(96, 28, 1.9),
        .init(142, 54, 1.3), .init(188, 22, 1.7), .init(224, 36, 1.4),
        .init(268, 16, 2.1), .init(310, 48, 1.3), .init(356, 34, 1.6),
        .init(392, 20, 1.2), .init(430, 40, 1.5), .init(26, 64, 1.3),
        .init(210, 70, 1.1), .init(340, 66, 1.2), .init(120, 12, 1.5),
        .init(280, 10, 1.6), .init(400, 12, 1.3), .init(60, 10, 1.2)
    ]
    let sx = size.width / 430.0
    let sy = max(size.height, 1) / 90.0
    return Array(base.prefix(count)).map { p in
        StarPoint(p.x * sx, p.y * sy, max(1.0, p.r))
    }
}

private struct StarPoint { let x: CGFloat; let y: CGFloat; let r: CGFloat
    init(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat) { self.x=x; self.y=y; self.r=r }
}

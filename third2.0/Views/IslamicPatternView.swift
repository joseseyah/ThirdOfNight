import SwiftUI

struct IslamicPatternView: View {
    let primaryColor = Color("BoxBackgroundColor")
    let accentColor = Color("HighlightColor")
    let backgroundColor = Color(hex: "#0A1B3D") // Rich dark blue

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let tileSize: CGFloat = size.width / 5 // Adjust for a tighter grid

            ZStack {
                // Background
                backgroundColor
                    .edgesIgnoringSafeArea(.all)

                // Pattern
                ForEach(0..<Int(size.height / tileSize), id: \.self) { row in
                    ForEach(0..<Int(size.width / tileSize), id: \.self) { column in
                        let xOffset = CGFloat(column) * tileSize
                        let yOffset = CGFloat(row) * tileSize

                        // Arches and decorative shapes
                        if (row + column) % 2 == 0 {
                            createArch(tileSize: tileSize * 0.8)
                                .fill(primaryColor.opacity(0.1))
                                .frame(width: tileSize, height: tileSize)
                                .position(x: xOffset + tileSize / 2, y: yOffset + tileSize / 2)
                        } else {
                            createStar(tileSize: tileSize * 0.6)
                                .fill(accentColor.opacity(0.5))
                                .frame(width: tileSize, height: tileSize)
                                .position(x: xOffset + tileSize / 2, y: yOffset + tileSize / 2)
                        }
                    }
                }
            }
        }
    }

    // Create an arch shape
    func createArch(tileSize: CGFloat) -> Path {
        Path { path in
            let center = CGPoint(x: tileSize / 2, y: tileSize / 2)
            let radius = tileSize / 2

            path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
            path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
            path.addLine(to: CGPoint(x: center.x - radius, y: center.y))
            path.closeSubpath()
        }
    }

    // Create a star shape
    func createStar(tileSize: CGFloat) -> Path {
        Path { path in
            let center = CGPoint(x: tileSize / 2, y: tileSize / 2)
            let points = 8
            let angle = (2 * .pi) / CGFloat(points)
            let radius = tileSize / 2

            for i in 0..<points {
                let radiusModifier = i % 2 == 0 ? radius : radius * 0.5
                let x = center.x + radiusModifier * cos(CGFloat(i) * angle)
                let y = center.y + radiusModifier * sin(CGFloat(i) * angle)

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
        }
    }
}

struct IslamicPatternView_Previews: PreviewProvider {
    static var previews: some View {
        IslamicPatternView()
            .previewLayout(.sizeThatFits)
            .frame(width: 300, height: 300)
    }
}

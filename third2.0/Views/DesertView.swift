//
//  DesertView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 14/10/2024.
//

import Foundation
import SwiftUI
// Simple desert shape made with curves for the dunes
struct DesertView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height

                // Draw the desert dunes
                path.move(to: CGPoint(x: 0, y: height * 0.7))
                path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height * 0.6), control: CGPoint(x: width * 0.25, y: height * 0.55))
                path.addQuadCurve(to: CGPoint(x: width, y: height * 0.7), control: CGPoint(x: width * 0.75, y: height * 0.65))
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(Color(hex: "#FDF3E7"))  // Light cream desert color
        }
    }
}

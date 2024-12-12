//
//  StarrySkyView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 14/10/2024.
//

import Foundation
import SwiftUI

// Starry Sky with randomly placed dots (stars)
struct StarrySkyView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50) { _ in  // 50 random stars
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.7)  // Keep stars in the upper area
                        )
                }
            }
        }
        .ignoresSafeArea()
    }
}

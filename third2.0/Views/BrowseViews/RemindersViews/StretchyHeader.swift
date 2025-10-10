//
//  StretchyHeader.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 09/10/2025.
//
import SwiftUI

struct StretchyHeader<Background: View, Content: View>: View {
    var baseHeight: CGFloat
    var cornerRadius: CGFloat = 26
    @ViewBuilder var background: (_ height: CGFloat) -> Background
    @ViewBuilder var content: (_ height: CGFloat, _ topInset: CGFloat) -> Content

    var body: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("tipsScroll")).minY
            let extra = max(0, minY)                 // stretch when pulling down
            let height = baseHeight + extra
            let topInset = proxy.safeAreaInsets.top  // status-bar height

            ZStack {
                background(height)
                content(height, topInset)
                    .padding(.top, topInset + 8)     // keep below status bar
            }
            .frame(height: height)
            .offset(y: -extra)                        // pin to top while stretching
            .mask(BottomRoundedMask(radius: cornerRadius))
            .overlay(
                BottomRoundedMask(radius: cornerRadius)
                    .stroke(Color.stroke, lineWidth: 1)
            )
        }
        .frame(height: baseHeight)                    // reader’s base size
        .ignoresSafeArea(edges: .top)
    }
}

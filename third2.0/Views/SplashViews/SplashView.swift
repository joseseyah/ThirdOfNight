//
//  SplashView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 05/11/2025.
//


import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            Image("moon")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .shadow(color: .accentYellow.opacity(0.25), radius: 18, x: 0, y: 0)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.35)) {
                        opacity = 1.0
                    }
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        scale = 1.03
                    }
                }
        }
        .accessibilityHidden(true)
    }
}

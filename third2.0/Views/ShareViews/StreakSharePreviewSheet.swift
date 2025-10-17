//
//  StreakSharePreviewSheet.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 17/10/2025.
//


import SwiftUI

struct StreakSharePreviewSheet: View {
    let image: UIImage
    var onClose: () -> Void
    var onShare: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Big preview
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: w, height: h)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(radius: 20)
                }
                .padding(.horizontal, 16)

                HStack(spacing: 12) {
                    Button(action: onClose) {
                        Label("Close", systemImage: "xmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 16).padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.10)))
                    }
                    Button(action: onShare) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 16).padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentYellow.opacity(0.20)))
                    }
                }
                .foregroundColor(.textPrimary)
                .padding(.bottom, 8)
            }
            .padding(.top, 12)
            .background(Color.appBg.ignoresSafeArea())
            .navigationTitle("Share Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

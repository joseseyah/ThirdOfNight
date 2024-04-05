//
//  PrayerTimeView.swift
//  third
//
//  Created by Joseph Hayes on 29/03/2024.
//

import Foundation
import SwiftUI

struct PrayerTimeView: View {
    let title: String
    let time: String
    
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 5) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(height: 50)
                .overlay(
                    Text(time)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.5).delay(0.2)) {
                                self.isAnimating = true
                            }
                        }
                )
                .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .scaleEffect(isAnimating ? 1.0 : 0.7)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.5).delay(0.1)) {
                self.isAnimating = true
            }
        }
    }
}





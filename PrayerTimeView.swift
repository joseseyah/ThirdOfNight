//
//  PrayerTimeView.swift
//  third
//
//  Created by Joseph Hayes on 29/03/2024.
//

import Foundation
import SwiftUI

import SwiftUI

struct PrayerTimeView: View {
    let title: String
    let time: String
    
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 5) {
            Text(title.uppercased()) // Display the title (Fajr or Maghrib)
                .font(.caption)
                .foregroundColor(.gray)
            
            // White box containing the prayer time
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(height: 50)
                .overlay(
                    Text(time) // Display the prayer time
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .opacity(isAnimating ? 1.0 : 0.0) // Fade in effect when animating
                        .animation(Animation.easeInOut(duration: 0.5).delay(0.2)) // Delayed fade in animation
                )
                .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .scaleEffect(isAnimating ? 1.0 : 0.7) // Scale in effect when animating
        .animation(Animation.easeInOut(duration: 0.5).delay(0.1)) // Delayed scale in animation
        .onAppear {
            withAnimation {
                self.isAnimating = true
            }
        }
    }
}




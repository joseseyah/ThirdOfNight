//
//  MignightTimeView.swift
//  third
//
//  Created by Joseph Hayes on 31/03/2024.
//

import SwiftUI

struct MidnightTimeView: View {
    let midnightTime: String
    @State private var isShowing = false // State variable to toggle animation

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Isha ends") // Label indicating the significance of the time
                    .font(.caption)
                    .foregroundColor(Color(red: 0/255, green: 121/255, blue: 153/255)) // Same color as Islamic date
                    .padding(.leading, 20)
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(height: 50)
                .overlay(
                    Text(midnightTime)
                        .font(.subheadline)
                        .foregroundColor(.black)
                )
                .padding(.horizontal, 20)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // Add a subtle shadow for depth
                .scaleEffect(isShowing ? 1.0 : 0.5) // Scale effect for animation
                .animation(.spring()) // Spring animation effect
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color(red: 204/255, green: 229/255, blue: 255/255)) // Use your app's theme color here
        .cornerRadius(15) // Rounded corners for the container
        .onAppear {
            isShowing.toggle() // Toggle animation when view appears
        }
    }
}





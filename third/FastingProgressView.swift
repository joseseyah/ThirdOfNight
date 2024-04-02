//
//  FastingProgressView.swift
//  third
//
//  Created by Joseph Hayes on 31/03/2024.
//

import Foundation
import SwiftUI

struct FastingProgressView: View {
    let progress: Double
    let remainingTime: String // Time remaining until Iftar

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Progress Left till Iftar")
                    .font(.caption)
                    .foregroundColor(Color(red: 0/255, green: 121/255, blue: 153/255)) // Same color as Islamic date
                    .padding(.leading, 20)
                Spacer()
                Text("Time Left: \(remainingTime)")
                    .font(.caption)
                    .foregroundColor(Color(red: 0/255, green: 121/255, blue: 153/255)) // Same color as Islamic date
                    .padding(.trailing, 20)
            }

            // Progress bar with custom styling
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(progressColor()) // Fill color based on remaining time
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(width: CGFloat(progress) * 150, height: 10) // Adjust width based on progress
            }
            .frame(height: 10)
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }

    // Function to calculate progress bar color based on remaining time
    private func progressColor() -> Color {
        // Split remaining time string to get hours and minutes
        let components = remainingTime.split(separator: ":")
        guard components.count == 2,
              let remainingHours = Int(components[0]),
              let remainingMinutes = Int(components[1]) else {
            return .blue // Default color
        }
        
        // Calculate remaining time in minutes
        let totalRemainingMinutes = remainingHours * 60 + remainingMinutes
        
        // Total fasting duration (in minutes)
        let totalFastingMinutes = 12 * 60 // Assuming fasting duration from Fajr to Maghrib is 12 hours
        
        // Calculate progress (from 0 to 1)
        let progress = 1 - (Double(totalRemainingMinutes) / Double(totalFastingMinutes))
        
        // Interpolate color between blue and white based on progress
        let red = 0.0 + (1.0 - progress) * 1.0
        let green = 0.0 + (1.0 - progress) * 1.0
        let blue = 1.0 - progress
        return Color(red: red, green: green, blue: blue)
    }

}






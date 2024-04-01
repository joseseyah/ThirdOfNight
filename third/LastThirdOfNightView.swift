//
//  LastThirdOfNightView.swift
//  third
//
//  Created by Joseph Hayes on 01/04/2024.
//

import Foundation

import SwiftUI

struct LastThirdOfNightTimelineView: View {
    let sunsetTime: String
    let midnightTime: String
    let lastThirdTime: String
    let fajrStartTime: String
    let currentTime: String

    var body: some View {
        VStack {
            Text("Timeline")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 20)

            HStack {
                Text(sunsetTime)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(midnightTime)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(lastThirdTime)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(fajrStartTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)

            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Timeline background
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                        .padding(.horizontal, 20)

                    // Markers
                    MarkerView(color: .orange, time: sunsetTime, geometry: geometry)
                    MarkerView(color: .blue, time: midnightTime, geometry: geometry)
                    MarkerView(color: .green, time: lastThirdTime, geometry: geometry)
                    MarkerView(color: .purple, time: fajrStartTime, geometry: geometry)
                    MarkerView(color: .red, time: currentTime, geometry: geometry)
                }
                .padding(.vertical, 20)
            }
            .frame(height: 50)
        }
        .padding(.horizontal)
    }
}

struct MarkerView: View {
    let color: Color
    let time: String
    let geometry: GeometryProxy

    var body: some View {
        let position = getXPosition(for: time, in: geometry.size.width)

        VStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .offset(x: position - 5, y: 0)

            Text(time)
                .font(.caption)
                .foregroundColor(.gray)
                .offset(x: position - 20, y: 0)
        }
    }

    // Helper function to calculate the X position for markers
    private func getXPosition(for time: String, in width: CGFloat) -> CGFloat {
        // Assuming sunset is at the start of the timeline and sunrise is at the end
        let sunsetPercentage = 0.0 // Replace with the actual sunset time percentage
        let sunrisePercentage = 1.0 // Replace with the actual sunrise time percentage
        let timePercentage = 0.5 // Replace with the actual time percentage
        
        let startPosition = sunsetPercentage * width
        let endPosition = sunrisePercentage * width
        let position = startPosition + (endPosition - startPosition) * CGFloat(timePercentage)
        
        return position
    }
}






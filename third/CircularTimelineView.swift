//
//  CircularTimelineView.swift
//  third
//
//  Created by Joseph Hayes on 01/04/2024.
//

import Foundation

import SwiftUI

struct CircularTimelineView: View {
    let timings: [String]
    let trackerTime: String
    @State private var stageText = "" // State variable to track the stage text
    @State private var rotationAngle: Double = 0 // State variable to track rotation angle
    @State private var trackerAngle: Double = 0 // State variable to track tracker angle

    var body: some View {
        VStack {
            Spacer().frame(height: 10) // Add gap between MidnightTimeView and CircularTimelineView
            HStack {
                // Text "Night Cycle" at top left corner
                Text("Night Cyce")
                    .font(.caption)
                    .fontWeight(.bold) // Bold text
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                    .padding(.top, 5)
                
                Spacer() // Spacer to push stageText to the right
                // Stage text on the right side
                Text(stageText)
                    .font(.caption)
                    .fontWeight(.bold) // Bold text
                    .foregroundColor(.black)
                    .padding(.trailing, 10)
            }

            ZStack {
                // Rectangle container
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .frame(height: 170) // Adjusted height

                // Earth and orbit
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60) // Adjusted earth size
                        .overlay(
                            Image(systemName: "circle.grid.cross.fill")
                                .resizable()
                                .frame(width: 30, height: 30) // Adjusted earth icon size
                                .foregroundColor(.green)
                        )
                        .rotationEffect(.degrees(rotationAngle)) // Rotate the Earth
                    
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 120, height: 120) // Adjusted orbit size

                    // Timings markers
                    ForEach(0..<timings.count) { index in
                        let angle = -Double(index) / Double(timings.count) * 2 * .pi // Adjusted angle
                        let x = 60 * cos(angle)
                        let y = 60 * sin(angle)
                        let timing = timings[index]
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 10, height: 10)
                            .offset(x: CGFloat(x), y: CGFloat(y))
                            .overlay(
                                Text(timing)
                                    .foregroundColor(.white)
                            )
                    }

                    // Tracker
                    let trackerX = 60 * cos(trackerAngle)
                    let trackerY = 60 * sin(trackerAngle)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: CGFloat(trackerX), y: CGFloat(trackerY))
                }
            }
            .frame(height: 170) // Adjusted height
        }
        .onAppear {
            updateStageText()
            rotateEarth() // Start rotating the Earth on appear
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            updateStageText()
        }
    }
    
    private func updateStageText() {
        guard let currentTime = Double(trackerTime) else { return }

        if currentTime >= 0 && currentTime < 2.0 {
            stageText = "Isha Ended"
        } else if currentTime >= 2.0 && currentTime < 3.0 {
            stageText = "Last Third of Night"
        } else if currentTime >= 3.0 && currentTime < 5.0 {
            stageText = "Tahajjud Prayer"
        } else if currentTime >= 5.0 && currentTime < 6.0 {
            stageText = "Fajr Prayer"
        } else {
            stageText = "Sunrise"
        }
    }
    
    private func rotateEarth() {
        withAnimation(Animation.linear(duration: 10).repeatForever()) {
            rotationAngle += 360 // Rotate Earth by 360 degrees
        }
        updateTrackerAngle()
    }

    private func updateTrackerAngle() {
        guard let currentTime = Double(trackerTime) else { return }
        let totalTimings = Double(timings.count)
        let angle = (currentTime.truncatingRemainder(dividingBy: totalTimings) / totalTimings) * 2 * .pi // Adjusted angle
        self.trackerAngle = angle - .pi / 2 // Adjust angle for starting from top
    }
}

struct CircularTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        CircularTimelineView(timings: ["Sunset", "Midnight", "Last Third", "Fajr", "Sunrise"], trackerTime: "1")
            .padding()
            .previewLayout(.sizeThatFits)
    }
}





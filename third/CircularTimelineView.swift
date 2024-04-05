import SwiftUI

struct CircularTimelineView: View {
    let timings: [String]
    @State private var stageText = "" // State variable to track the stage text
    @State private var rotationAngle: Double = 0 // State variable to track rotation angle
    @State private var trackerAngle: Double = 0 // State variable to track tracker angle
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // Timer to update trackerTime
    @State private var trackerTime: String = ""

    var body: some View {
        VStack {
            Spacer().frame(height: 10) // Add gap between MidnightTimeView and CircularTimelineView
            HStack {
                // Text "Night Cycle" at top left corner
                Text("Night Cycle")
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

                    // Timings markers with labels
                    ForEach(0..<timings.count) { index in
                        let angle = -Double(index) / Double(timings.count) * 2 * .pi // Adjusted angle
                        let markerX = 60 * cos(angle)
                        let markerY = 60 * sin(angle)
                        let labelX = 85 * cos(angle) // Adjusted label position
                        let labelY = 85 * sin(angle) // Adjusted label position
                        let timing = timings[index]
                        
                        // Marker on the orbit line
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 10, height: 10)
                            .offset(x: CGFloat(markerX), y: CGFloat(markerY))
                        
                        // Label with arrow pointing outside the orbit
                        VStack {
                            Text(timing)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .offset(x: CGFloat(labelX), y: CGFloat(labelY))
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
            updateTrackerTime() // Update trackerTime initially
        }
        .onReceive(timer) { _ in
            updateTrackerTime() // Update trackerTime periodically
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            updateStageText()
        }
    }
    
    private func updateStageText() {
        guard let currentTime = Double(trackerTime) else { return }

        if currentTime >= 0 && currentTime < 5.0 {
            stageText = "Fajr Prayer"
        } else if currentTime >= 5.0 && currentTime < 18.0 {
            stageText = "Complete the fast"
        } else if currentTime >= 18.0 && currentTime < 24.0 {
            stageText = "Break Fast and pray"
        } else {
            stageText = "Isha has ended"
        }
    }
    
    private func rotateEarth() {
        withAnimation(Animation.linear(duration: 10).repeatForever()) {
            rotationAngle += 360 // Rotate Earth by 360 degrees
        }
    }

    private func updateTrackerTime() {
        // Get current time and convert it to string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H"
        trackerTime = dateFormatter.string(from: Date())
        
        // Calculate tracker angle based on current time
        guard let currentTime = Double(trackerTime) else { return }
        let totalTimings = Double(timings.count)
        let angle = (currentTime.truncatingRemainder(dividingBy: totalTimings) / totalTimings) * 2 * .pi // Adjusted angle
        self.trackerAngle = angle - .pi / 2 // Adjust angle for starting from top
    }
}

struct CircularTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        CircularTimelineView(timings: ["Sunset", "Midnight", "Last Third", "Fajr", "Sunrise"])
            .padding()
            .previewLayout(.sizeThatFits)
    }
}


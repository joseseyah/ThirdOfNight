import SwiftUI

struct CircularTimelineView: View {
    let timings: [String]
    @State private var stageText = ""
    @State private var rotationAngle: Double = 0
    @State private var trackerAngle: Double = 0
    @State private var trackerTime: String = ""
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Spacer().frame(height: 10)
            HStack {
                Text("Night Cycle")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white) // Adjusted to match the new color theme
                    .padding(.leading, 10)
                    .padding(.top, 5)
                Spacer()
                Text(stageText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white) // Adjusted to match the new color theme
                    .padding(.trailing, 10)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color(red: 26/255, green: 25/255, blue: 28/255),
                                    Color(red: 101/255, green: 126/255, blue: 154/255)
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 170)
                
                ZStack {
                    Circle()
                        .fill(Color(red: 101/255, green: 126/255, blue: 154/255)) // Adjusted to match the new color theme
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "circle.grid.cross.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.green)
                        )
                        .rotationEffect(.degrees(rotationAngle))

                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 120, height: 120)

                    ForEach(0..<timings.count) { index in
                        let angle = -Double(index) / Double(timings.count) * 2 * .pi
                        let markerX = 60 * cos(angle)
                        let markerY = 60 * sin(angle)
                        let labelX = 85 * cos(angle)
                        let labelY = 85 * sin(angle)
                        let timing = timings[index]
                        
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 10, height: 10)
                            .offset(x: CGFloat(markerX), y: CGFloat(markerY))
                        
                        VStack {
                            Text(timing)
                                .font(.caption)
                                .foregroundColor(Color.white) // Adjusted to match the new color theme
                        }
                        .offset(x: CGFloat(labelX), y: CGFloat(labelY))
                    }

                    let trackerX = 60 * cos(trackerAngle)
                    let trackerY = 60 * sin(trackerAngle)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: CGFloat(trackerX), y: CGFloat(trackerY))
                }
            }
            .frame(height: 170)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(red: 26/255, green: 25/255, blue: 28/255),
                        Color(red: 101/255, green: 126/255, blue: 154/255)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
        .onAppear {
            updateStageText()
            rotateEarth()
            updateTrackerTime()
        }
        .onReceive(timer) { _ in
            updateTrackerTime()
            updateStageText()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            updateStageText()
        }
    }
    
    private func updateStageText() {
        // Get the current time
        let currentDate = Date()
        
        // Calculate the current hour
        let calendar = Calendar.current
        let currentTime = calendar.component(.hour, from: currentDate)
        
        
        if currentTime >= 0 && currentTime < 5 {
            stageText = "Fajr Prayer"
        } else if currentTime >= 5 && currentTime < 18 {
            stageText = "Complete the fast"
        } else if currentTime >= 18 && currentTime < 24 {
            stageText = "Break Fast and pray"
        } else {
            stageText = "Isha has ended"
        }
    }
    
    private func rotateEarth() {
        withAnimation(Animation.linear(duration: 10).repeatForever()) {
            rotationAngle += 360
        }
    }

    private func updateTrackerTime() {
        // Get the current time
        let currentDate = Date()
        
        // Calculate the current second
        let calendar = Calendar.current
        let currentSecond = calendar.component(.hour, from: currentDate) // Change to .second
        
        // Calculate the angle based on the current second and the total number of timings
        let totalTimings = Double(timings.count)
        let angle = -(Double(currentSecond).truncatingRemainder(dividingBy: totalTimings) / totalTimings) * 2 * .pi // Change sign here
        
        // Set the tracker angle to rotate the red circle along the orbit
        self.trackerAngle = angle - .pi / 2
    }

}

struct CircularTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        CircularTimelineView(timings: ["Sunset", "Midnight", "Last Third", "Fajr", "Sunrise"])
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

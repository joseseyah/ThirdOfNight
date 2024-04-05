import SwiftUI

struct CircularTimelineView: View {
    let timings: [String]
    @State private var stageText = ""
    @State private var rotationAngle: Double = 0
    @State private var trackerAngle: Double = 0
    @State private var trackerTime: String = ""
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Spacer().frame(height: 10)
            HStack {
                Text("Night Cycle")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue) // Adjusted to match the new color theme
                    .padding(.leading, 10)
                    .padding(.top, 5)
                Spacer()
                Text(stageText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue) // Adjusted to match the new color theme
                    .padding(.trailing, 10)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .frame(height: 170)
                
                ZStack {
                    Circle()
                        .fill(Color.blue) // Adjusted to match the new color theme
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "circle.grid.cross.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.green)
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
                                .foregroundColor(.black) // Adjusted to match the new color theme
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
        .background(Color(red: 204/255, green: 229/255, blue: 255/255)) // Adjusted to match the new color theme
        .cornerRadius(15)
        .onAppear {
            updateStageText()
            rotateEarth()
            updateTrackerTime()
        }
        .onReceive(timer) { _ in
            updateTrackerTime()
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
            rotationAngle += 360
        }
    }

    private func updateTrackerTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H"
        trackerTime = dateFormatter.string(from: Date())
        
        guard let currentTime = Double(trackerTime) else { return }
        let totalTimings = Double(timings.count)
        let angle = (currentTime.truncatingRemainder(dividingBy: totalTimings) / totalTimings) * 2 * .pi
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


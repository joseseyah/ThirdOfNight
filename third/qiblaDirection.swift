import SwiftUI

struct QiblaDirectionView: View {
    @State private var direction: Double?
    
    let apiURL = "http://api.aladhan.com/v1/qibla/"
    let latitude = 25.4106386
    let longitude = 51.1846025
    
    var body: some View {
        VStack {
            if let direction = direction {
                CompassView(direction: direction)
                    .padding()
            } else {
                ProgressView()
                    .padding()
            }
        }
        .onAppear {
            fetchQiblaDirection()
        }
    }
    
    func fetchQiblaDirection() {
        guard let url = URL(string: "\(apiURL)\(latitude)/\(longitude)") else {
            print("Invalid API URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonData = json as? [String: Any],
                   let data = jsonData["data"] as? [String: Any],
                   let direction = data["direction"] as? Double {
                    DispatchQueue.main.async {
                        self.direction = direction
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
}

struct CompassView: View {
    let direction: Double
    
    var body: some View {
        VStack {
            Image(systemName: "location.north.line.fill")
                .font(.system(size: 100))
                .rotationEffect(.degrees(-direction))
                .padding()
            
            Text("Qibla Direction: \(String(format: "%.2f", direction))°")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding()
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

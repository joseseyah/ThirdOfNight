import SwiftUI

struct QiblaDirectionView: View {
    @State private var direction: Double?
    @State private var isLoading: Bool = false
    
    let apiURL = "http://api.aladhan.com/v1/qibla/"
    let latitude = 25.4106386
    let longitude = 51.1846025
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .padding()
            } else if let direction = direction {
                CompassView(direction: direction)
                    .padding()
            } else {
                Text("Failed to fetch Qibla direction.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            fetchQiblaDirection()
        }
    }
    
    func fetchQiblaDirection() {
        isLoading = true
        
        guard let url = URL(string: "\(apiURL)\(latitude)/\(longitude)") else {
            print("Invalid API URL")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            defer {
                isLoading = false
            }
            
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
            Image(systemName: "compass")
                .font(.system(size: 100))
                .rotationEffect(.degrees(-direction))
                .padding()
            
            Text("Compass Direction: \(String(format: "%.2f", direction))°")
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


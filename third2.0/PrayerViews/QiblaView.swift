import SwiftUI
import CoreLocation

struct QiblaView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CompassDirectionManager()

    var body: some View {
        ZStack {
            // Background gradient similar to Apple's design
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Qibla Direction")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                Spacer()

                ZStack {
                    // Main pointer arrow
                    Image(systemName: "arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 200) // Larger arrow
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(viewModel.smoothedQiblaRotation))

                    // Pulsating indicator dot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(y: -200)
                        .opacity(0.7)
                }
                .frame(width: 300, height: 300)

                Spacer()

                // Distance and instructions
                VStack(spacing: 10) {
                    if let distance = viewModel.distanceToQibla {
                        Text(String(format: "%.1f miles", distance))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Text("Calculating...")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    if viewModel.isAlignedWithQibla {
                        Text("You are aligned with the Qibla direction!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                }

                Spacer()

                // Close button
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            viewModel.requestAuthorizationAndInitManager()
        }
        .onDisappear {
            viewModel.stopUpdatingLocation()
        }
    }
}

class CompassDirectionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var northRotation: Double = 0.0
    @Published var qiblaRotation: Double = 0.0
    @Published var distanceToQibla: Double? = nil
    @Published var isAlignedWithQibla: Bool = false

    private let locationManager = CLLocationManager()
    private var latOfOrigin = 21.4225
    private var lngOfOrigin = 39.8262
    private var location: CLLocation?

    private var previousQiblaRotation: Double = 0.0
    private let smoothingFactor: Double = 0.1 // Adjust this to control the smoothing speed

    var smoothedQiblaRotation: Double {
        return previousQiblaRotation
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func requestAuthorizationAndInitManager() {
        // Request authorization; rely on the delegate callback for further actions
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // Start location updates only if services are enabled
            if CLLocationManager.locationServicesEnabled() {
                startUpdating()
            } else {
                handleLocationServicesDisabled()
            }
        case .notDetermined:
            // Wait for the user to make a decision
            print("Authorization status is not determined.")
        case .restricted, .denied:
            handleAuthorizationDenied()
        @unknown default:
            print("Unknown authorization status.")
        }
    }
    
    private func handleLocationServicesDisabled() {
        print("Location services are disabled. Prompt user to enable them.")
        // Optionally show an alert to guide the user
    }

    private func handleAuthorizationDenied() {
        print("Location permissions are denied. Prompt user to enable them in settings.")
        // Optionally show an alert or instructions
    }



    func startUpdating() {
        // Only start updates when properly authorized
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }



    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        let north = -1 * heading.magneticHeading
        let directionOfKabah = calculateQiblaDirection(north: north)

        DispatchQueue.main.async {
            self.northRotation = north
            self.previousQiblaRotation += (directionOfKabah - self.previousQiblaRotation) * self.smoothingFactor

            self.isAlignedWithQibla = abs(directionOfKabah.truncatingRemainder(dividingBy: 360)) < 5 // Check if within 5 degrees of alignment
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        location = userLocation
        qiblaRotation = calculateBearing(from: userLocation)
        distanceToQibla = calculateDistance(from: userLocation)
    }

    private func calculateQiblaDirection(north: Double) -> Double {
        let qiblaDirection = qiblaRotation + north
        return qiblaDirection.truncatingRemainder(dividingBy: 360)
    }

    private func calculateBearing(from location: CLLocation) -> Double {
        let lat1 = degreesToRadians(location.coordinate.latitude)
        let lon1 = degreesToRadians(location.coordinate.longitude)
        let lat2 = degreesToRadians(latOfOrigin)
        let lon2 = degreesToRadians(lngOfOrigin)

        let deltaLon = lon2 - lon1

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        var bearing = atan2(y, x)
        bearing = radiansToDegrees(bearing)
        if bearing < 0 { bearing += 360 }

        return bearing
    }

    private func calculateDistance(from location: CLLocation) -> Double {
        let userLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let qiblaLocation = CLLocation(latitude: latOfOrigin, longitude: lngOfOrigin)
        let distanceInMeters = userLocation.distance(from: qiblaLocation)
        return distanceInMeters / 1609.34 // Convert meters to miles
    }

    private func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }

    private func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180 / Double.pi
    }
}

import SwiftUI
import CoreLocation
import Combine

// MARK: - QiblaView with stationary pointer & rotating face
struct QiblaView: View {
    @StateObject private var vm = QiblaCompassViewModel()

    // Assets
    private let compassAssetName = "Compass"
    private let pointerAssetName = "Pointer"

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            StarOverlay(count: 38, maxYFraction: 0.7, opacity: 0.40)

            GeometryReader { geo in
                VStack(spacing: 16) {
                    Spacer(minLength: geo.size.height * 0.08)

                    CompassWidget(
                        faceAsset: compassAssetName,
                        pointerAsset: pointerAssetName,
                        size: 300,
                        // FACE rotates; pointer is fixed
                        faceRotationDegrees: vm.faceRotationDegrees,
                        pointerTint: .accentYellow,
                        pointerScale: 0.25
                    )
                    .frame(maxWidth: .infinity)

                    Group {
                        if let distance = vm.distanceMiles {
                            VStack(spacing: 6) {
                                Text(String(format: "%.1f miles", distance))
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.accentYellow)

                                Text("to the Qibla from your current location")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 14)
                            .frame(maxWidth: 420)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.cardBg)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                            .padding(.top, 6)
                            .padding(.horizontal, 20)
                        } else {
                            Text(vm.statusText)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .frame(maxWidth: 420)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.cardBg)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.stroke, lineWidth: 1)
                                )
                                .padding(.top, 6)
                                .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: geo.size.height * 0.12)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .padding(.bottom, geo.safeAreaInsets.bottom + 6)
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

// MARK: - Compass (rotating face + stationary pointer)
private struct CompassWidget: View {
    let faceAsset: String
    let pointerAsset: String
    let size: CGFloat
    let faceRotationDegrees: Double
    var pointerTint: Color = .accentYellow
    var pointerScale: CGFloat = 0.44

    var body: some View {
        ZStack {
            // Face rotates to bring the Mecca mark under the fixed pointer
            Image(faceAsset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .rotationEffect(.degrees(faceRotationDegrees))
                .animation(.spring(response: 0.25, dampingFraction: 0.85), value: faceRotationDegrees)

            // Pointer stays still (no rotation)
            Image(pointerAsset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(pointerTint)
                .frame(width: size * pointerScale, height: size * pointerScale)
                .allowsHitTesting(false)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - ViewModel (Location + Heading -> face rotation)
final class QiblaCompassViewModel: NSObject, ObservableObject {
    // Output
    @Published var faceRotationDegrees: Double = 0        // rotate the face, not the pointer
    @Published var statusText: String = "Calibrating compass…"
    @Published var distanceMiles: Double? = nil

    // Internals
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation? = nil
    private var lastHeadingTrue: CLLocationDirection? = nil

    private let kaaba = CLLocation(latitude: 21.422487, longitude: 39.826206)

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1
    }

    func start() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            manager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            }
        }
    }

    func stop() {
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }

    private func updateOutputs() {
        guard
            let loc = lastLocation,
            let heading = lastHeadingTrue
        else { return }

        // Bearing from user to Kaaba (0..360, True)
        let bearing = bearingTrue(from: loc.coordinate, to: kaaba.coordinate)

        // Distance (miles)
        let meters = loc.distance(from: kaaba)
        distanceMiles = meters / 1609.344

        let rotation = normalizeDegrees(heading - bearing)
        faceRotationDegrees = rotation

        statusText = "Rotate to align the mark with the pointer"
    }

    private func bearingTrue(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> CLLocationDegrees {
        let φ1 = a.latitude  * .pi / 180
        let φ2 = b.latitude  * .pi / 180
        let λ1 = a.longitude * .pi / 180
        let λ2 = b.longitude * .pi / 180
        let y = sin(λ2 - λ1) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(λ2 - λ1)
        let θ = atan2(y, x) * 180 / .pi
        return normalizeDegrees(θ)
    }

    private func normalizeDegrees(_ d: CLLocationDegrees) -> CLLocationDegrees {
        var v = d.truncatingRemainder(dividingBy: 360)
        if v < -180 { v += 360 }
        if v >  180 { v -= 360 }
        return v
    }
}

// MARK: - CLLocationManagerDelegate
extension QiblaCompassViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            statusText = "Calibrating compass…"
            manager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            } else {
                statusText = "Compass not available on this device"
            }
        case .denied, .restricted:
            statusText = "Enable Location & Motion access in Settings"
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latest = locations.last {
            lastLocation = latest
            updateOutputs()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        statusText = "Location error: \(error.localizedDescription)"
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Prefer TRUE heading when available
        let h = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        lastHeadingTrue = h
        updateOutputs()
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        // Let iOS show calibration if needed
        true
    }
}

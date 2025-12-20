import SwiftUI
import CoreLocation
import Combine
import UIKit

// MARK: - QiblaView with stationary pointer & smooth, unwrapped rotating face
struct QiblaView: View {
    @StateObject private var vm = QiblaCompassViewModel()

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
                        faceRotationDegrees: vm.faceRotationDegrees,
                        pointerTint: .accentMoon,
                        pointerScale: 0.25
                    )
                    .frame(maxWidth: .infinity)

                    Group {
                        if let distance = vm.distanceMiles {
                            VStack(spacing: 6) {
                                Text(String(format: "%.1f miles", distance))
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.accentMoon)

                                Text(String(localized: "to the Qibla from your current location"))
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

                    if vm.isAligned {
                        Text(String(localized: "You're facing Makkah"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appBg)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Capsule().fill(Color.accentMoon))
                            .overlay(Capsule().stroke(Color.stroke, lineWidth: 1))
                            .padding(.top, 4)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: vm.isAligned)
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
    var pointerTint: Color = .accentMoon
    var pointerScale: CGFloat = 0.44

    var body: some View {
        ZStack {
            // Face rotates to bring the Mecca mark under the fixed pointer
            Image(faceAsset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .rotationEffect(.degrees(faceRotationDegrees))
                .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.88), value: faceRotationDegrees)

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

// MARK: - ViewModel (Location + Heading -> smooth, unwrapped face rotation + haptics)
final class QiblaCompassViewModel: NSObject, ObservableObject {
    // Output
    @Published var faceRotationDegrees: Double = 0        // continuous, unwrapped degrees
    @Published var statusText: String = "Calibrating compass…"
    @Published var distanceMiles: Double? = nil
    @Published var isAligned: Bool = false

    // Internals
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation? = nil
    private var lastHeadingTrue: CLLocationDirection? = nil

    // Angle state for unwrapping (avoid flips at 180°/−180°)
    private var accumulatedFaceRotation: Double = 0       // continuous angle we publish
    private var lastTargetModulo: Double? = nil           // last target in [0, 360)

    // Haptics
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let notify = UINotificationFeedbackGenerator()
    private var didAnnounceAligned = false
    private var lastTickTime: Date = .distantPast

    // Tunables
    private let alignTolerance: CLLocationDegrees = 5       // ± degrees to show "facing Makkah"
    private let tickStep: CLLocationDegrees = 12            // degrees between light tick feedback
    private let tickCooldown: TimeInterval = 0.08           // debounce ticks

    private let kaaba = CLLocation(latitude: 21.422487, longitude: 39.826206)

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1
    }

  func start() {
      impactLight.prepare()
      notify.prepare()

      let status = manager.authorizationStatus

      switch status {
      case .notDetermined:
          manager.requestWhenInUseAuthorization()

      case .authorizedWhenInUse, .authorizedAlways:
          manager.startUpdatingLocation()

          if CLLocationManager.headingAvailable() {
              manager.startUpdatingHeading()
          } else {
              DispatchQueue.main.async {
                  self.statusText = "Compass not available on this device"
              }
          }

      case .restricted, .denied:
          DispatchQueue.main.async {
              self.statusText = "Location access is needed for the compass"
          }

      @unknown default:
          break
      }
  }


    func stop() {
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }

    // MARK: - Core updates
    private func updateOutputs() {
        guard
            let loc = lastLocation,
            let heading = lastHeadingTrue
        else { return }

        // Bearing from user to Kaaba (0..360, True)
        let bearing = bearingTrue(from: loc.coordinate, to: kaaba.coordinate)

        // Distance (miles)
        let meters = loc.distance(from: kaaba)
        let miles = meters / 1609.344

        // Target rotation for the FACE so the Mecca mark sits under the fixed pointer.
        // Earlier code used normalize to ±180 which causes flips.
        // Here we compute the target in [0, 360) then UNWRAP to a continuous angle.
        // sign: rotate the face by (heading - bearing)
        let target = mod360(heading - bearing) // [0, 360)

        // Unwrap to the shortest path from the previous target
        let unwrapped = nextUnwrappedAngle(currentAccumulated: accumulatedFaceRotation,
                                           previousTargetModulo: lastTargetModulo,
                                           newTargetModulo: target)

        accumulatedFaceRotation = unwrapped
        lastTargetModulo = target

        // Publish
        DispatchQueue.main.async {
            self.distanceMiles = miles
            self.faceRotationDegrees = self.accumulatedFaceRotation
            self.statusText = "Rotate to align the mark with the pointer"
        }

        // Alignment check (use the *wrapped* instantaneous error around 0)
        let wrappedError = shortestDeltaDegrees(from: 0, to: wrappedTo180(accumulatedFaceRotation))
        let nowAligned = abs(wrappedError) <= alignTolerance
        if nowAligned != isAligned {
            DispatchQueue.main.async { self.isAligned = nowAligned }
        }

        // HAPTICS
        if nowAligned && !didAnnounceAligned {
            notify.notificationOccurred(.success)
            didAnnounceAligned = true
            UIAccessibility.post(notification: .announcement, argument: "Facing Makkah")
        } else if !nowAligned && didAnnounceAligned {
            didAnnounceAligned = false
        }

        // Light ticks while rotating every ~tickStep°, debounced
        let t = Date()
        if t.timeIntervalSince(lastTickTime) >= tickCooldown {
            // Compare movement since the *last* published angle using modulo distance
            // We simply trigger ticks on substantial changes of target modulo.
            if let prev = lastTargetModulo {
                let moved = abs(shortestDeltaDegrees(from: prev, to: target))
                if moved >= tickStep {
                    impactLight.impactOccurred()
                    impactLight.prepare()
                    lastTickTime = t
                }
            } else {
                lastTickTime = t
            }
        }
    }

    // MARK: - Angle helpers
    /// Normalize any angle to [0, 360)
    private func mod360(_ d: Double) -> Double {
        let m = d.truncatingRemainder(dividingBy: 360)
        return m < 0 ? (m + 360) : m
    }

    /// Wrap any angle to [-180, 180)
    private func wrappedTo180(_ d: Double) -> Double {
        var x = d.truncatingRemainder(dividingBy: 360)
        if x >= 180 { x -= 360 }
        if x < -180 { x += 360 }
        return x
    }

    /// Minimal signed delta from `from` to `to` in degrees in [-180, 180)
    private func shortestDeltaDegrees(from: Double, to: Double) -> Double {
        var d = (to - from).truncatingRemainder(dividingBy: 360)
        if d >= 180 { d -= 360 }
        if d < -180 { d += 360 }
        return d
    }

    /// Given the previous accumulated angle and a new target in [0, 360),
    /// produce a continuous, unwrapped next angle by adding the shortest delta.
    private func nextUnwrappedAngle(currentAccumulated: Double,
                                    previousTargetModulo: Double?,
                                    newTargetModulo: Double) -> Double {
        // If we don't have a previous target, align accumulated to the first target without animation jump.
        guard let prev = previousTargetModulo else {
            return newTargetModulo
        }
        // Compute how much we should move relative to the *previous* modulo target.
        let delta = shortestDeltaDegrees(from: prev, to: newTargetModulo)
        return currentAccumulated + delta
    }

    private func bearingTrue(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> CLLocationDegrees {
        let φ1 = a.latitude  * .pi / 180
        let φ2 = b.latitude  * .pi / 180
        let λ1 = a.longitude * .pi / 180
        let λ2 = b.longitude * .pi / 180
        let y = sin(λ2 - λ1) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(λ2 - λ1)
        let θ = atan2(y, x) * 180 / .pi
        // Return in [0, 360)
        return mod360(θ)
    }
}

// MARK: - CLLocationManagerDelegate
extension QiblaCompassViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async { self.statusText = "Calibrating compass…" }
            manager.startUpdatingLocation()
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            } else {
                DispatchQueue.main.async {
                    self.statusText = "Compass not available on this device"
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.statusText = "Enable Location & Motion access in Settings"
            }
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
        DispatchQueue.main.async {
            self.statusText = "Location error: \(error.localizedDescription)"
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Prefer TRUE heading when available
        let h = (newHeading.trueHeading >= 0) ? newHeading.trueHeading : newHeading.magneticHeading
        lastHeadingTrue = h
        updateOutputs()
    }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        true
    }
}

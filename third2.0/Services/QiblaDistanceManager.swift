//
//  QiblaDistanceManager.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import Combine
import CoreLocation


class QiblaDistanceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var distanceToQibla: Double? = nil

    private let locationManager = CLLocationManager()
    private let latOfOrigin = 21.4225
    private let lngOfOrigin = 39.8262

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func requestAuthorizationAndInitManager() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location permissions are not granted.")
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        distanceToQibla = calculateDistance(from: userLocation)
    }

    private func calculateDistance(from location: CLLocation) -> Double {
        let userLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let qiblaLocation = CLLocation(latitude: latOfOrigin, longitude: lngOfOrigin)
        let distanceInMeters = userLocation.distance(from: qiblaLocation)
        return distanceInMeters / 1609.34 // Convert meters to miles
    }
}

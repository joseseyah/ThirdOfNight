//
//  MiniLocationManager.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//


import CoreLocation
import Combine

final class MiniLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // Track authorization status via delegate callback to avoid thread issues
    private var currentAuthorizationStatus: CLAuthorizationStatus = .notDetermined

    @Published var coordinate: CLLocationCoordinate2D?
    @Published var placeName: String = "" 

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func request() {
        // Check location services enabled asynchronously to avoid blocking main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            guard CLLocationManager.locationServicesEnabled() else {
                DispatchQueue.main.async {
                    self.placeName = "Location Off"
                }
                return
            }
            
            // Request authorization - the delegate callback will handle the response
            // This avoids directly checking authorizationStatus which can cause thread issues
            // The locationManagerDidChangeAuthorization callback will be called automatically
            // by the system when authorization status changes or when delegate is first set
            DispatchQueue.main.async {
                self.manager.requestWhenInUseAuthorization()
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Use the newer delegate method to avoid thread issues
        // This method is called automatically when authorization changes
        // and is the recommended way to check authorization status
        let status = manager.authorizationStatus
        currentAuthorizationStatus = status
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            placeName = "Location Off"
        case .notDetermined:
            // Still waiting for user response, do nothing
            break
        @unknown default:
            placeName = "Location Off"
        }
    }
    
    // Keep the old method for compatibility but use the new one primarily
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManagerDidChangeAuthorization(manager)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        coordinate = loc.coordinate
        
        // Save location to App Group UserDefaults for widget access
        // This allows the widget extension to access the same data
        let appGroupID = "group.testing.thirdgit"
        let defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
        defaults.set(loc.coordinate.latitude, forKey: "last_lat")
        defaults.set(loc.coordinate.longitude, forKey: "last_lon")
        defaults.synchronize() // Ensure it's written immediately
        
        // Also save to standard UserDefaults as backup
        UserDefaults.standard.set(loc.coordinate.latitude, forKey: "last_lat")
        UserDefaults.standard.set(loc.coordinate.longitude, forKey: "last_lon")
        UserDefaults.standard.synchronize()
        
        reverseGeocode(loc)
        manager.stopUpdatingLocation()
    }

    // MARK: - Geocoding

    private func reverseGeocode(_ location: CLLocation) {
        if geocoder.isGeocoding { geocoder.cancelGeocode() }

        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { [weak self] placemarks, _ in
            guard let self, let pm = placemarks?.first else { return }

            // Prefer city/locality; fall back through sensible options
            let city = pm.locality
                ?? pm.subLocality
                ?? pm.subAdministrativeArea
                ?? pm.administrativeArea

            // Use full country name if available; fallback to ISO code
            let country = pm.country ?? pm.isoCountryCode

            DispatchQueue.main.async {
                if let city, let country {
                    self.placeName = "\(city), \(country)"
                } else if let city {
                    self.placeName = city
                } else if let country {
                    self.placeName = country
                } else {
                    self.placeName = "Current Location"
                }
            }
        }
    }
}

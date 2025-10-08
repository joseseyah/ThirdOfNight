import CoreLocation
import Combine

final class MiniLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var coordinate: CLLocationCoordinate2D?
    @Published var placeName: String = ""   // e.g. "London, United Kingdom"

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func request() {
        guard CLLocationManager.locationServicesEnabled() else {
            placeName = "Location Off"
            return
        }
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            placeName = "Location Off"
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            placeName = "Location Off"
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        coordinate = loc.coordinate
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

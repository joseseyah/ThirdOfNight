import SwiftUI
import CoreLocation

struct QiblaView: View {
    @StateObject private var viewModel = QiblaDistanceManager()

    var body: some View {
        ZStack {
            // Background color to match the theme
            Color("BackgroundColor")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Qibla Distance")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("HighlightColor"))
                        .padding(.top, 40)

                    // Distance Display
                    VStack(spacing: 10) {
                        if let distance = viewModel.distanceToQibla {
                            Text(String(format: "%.1f miles to the Qibla", distance))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("HighlightColor"))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color("BoxBackgroundColor"))
                                )
                        } else {
                            Text("Calculating distance...")
                                .font(.headline)
                                .foregroundColor(Color("HighlightColor"))
                        }
                    }

                    // Travel Dua Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Travel Duas")
                            .font(.headline)
                            .foregroundColor(Color("HighlightColor"))

                        DuaView(title: "Dua for Travelling", arabic: "بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ", translation: "I begin with the Name of Allah; I trust in Allah; there is no altering of conditions but by the Power of Allah.")

                        DuaView(title: "Dua When Boarding a Vehicle", arabic: "بِسْمِ اللَّهِ، وَالْحَمْدُ لِلَّهِ، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ", translation: "In the name of Allah and all praise is for Allah. How perfect He is, the One Who has placed this (transport) at our service and we ourselves would not have been capable of that, and to our Lord is our final destiny.")

                        DuaView(title: "Dua Upon Arrival", arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ", translation: "I seek refuge in Allah’s perfect words from every evil (that has been created).")

                        DuaView(title: "Talbiyah Dua for Hajj or Umrah", arabic: "لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ", translation: "Here I am, O Allah, here I am, here I am. You have no partner, here I am. Verily all praise and blessings are Yours, and all sovereignty. You have no partner.")

                        DuaView(title: "Dua for Return", arabic: "آيِبُونَ تَائِبُونَ عَابِدُونَ سَاجِدُونَ لِرَبِّنَا حَامِدُونَ", translation: "We return, repentant, worshipping, prostrating and praising our Lord.")

                        Text("Don’t forget to make lots of Dua’s during Hajj and Umrah, asking Allah (SWT) for forgiveness. Don’t forget to include your friends, relatives, neighbours as well as the wider Ummah in your Dua during these spiritual journeys.")
                            .font(.footnote)
                            .foregroundColor(Color("HighlightColor"))
                            .padding(.top, 10)
                    }
                    .padding()
                }
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

struct DuaView: View {
    let title: String
    let arabic: String
    let translation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("HighlightColor"))

            Text(arabic)
                .font(.body)
                .foregroundColor(Color("HighlightColor"))

            Text(translation)
                .font(.footnote)
                .italic()
                .foregroundColor(Color("HighlightColor"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("BoxBackgroundColor"))
        )
    }
}

class QiblaDistanceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var distanceToQibla: Double? = nil

    private let locationManager = CLLocationManager()
    private let latOfOrigin = 21.4225 // Latitude of Kaaba
    private let lngOfOrigin = 39.8262 // Longitude of Kaaba

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

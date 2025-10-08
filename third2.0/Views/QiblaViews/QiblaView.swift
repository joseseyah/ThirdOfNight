import SwiftUI
import CoreLocation

struct QiblaView: View {
    @StateObject private var viewModel = QiblaDistanceManager()

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("Qibla Distance")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("HighlightColor"))
                        .padding(.top, 40)

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
                    DuaSectionView()
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

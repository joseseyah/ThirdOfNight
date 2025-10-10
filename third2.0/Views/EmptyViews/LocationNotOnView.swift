import SwiftUI

struct LocationNotOnView: View {
    @StateObject var loc: MiniLocationManager

    var body: some View {
        ContentUnavailableView {
            Label("Location Needed", systemImage: "location.slash")
                .foregroundStyle(.white)
        } description: {
            Text("Enable location access to calculate local prayer times.")
                .foregroundStyle(.white)
        } actions: {
            HStack(spacing: 12) {
                Button("Try Again") { loc.request() }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentYellow)
                    .foregroundStyle(Color.appBg)

                Button("Open Settings") { openAppSettings() }
                    .buttonStyle(.bordered)
                    .tint(.accentYellow)
            }
        }
        .padding(.horizontal, 20)
        .preferredColorScheme(.dark)
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

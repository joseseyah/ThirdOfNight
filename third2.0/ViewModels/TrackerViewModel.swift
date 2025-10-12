import Foundation
import SwiftUI
import CoreLocation
import Combine

final class TrackerViewModel: ObservableObject {
    // Public state
    @Published var prayers: [PrayerItem] = []
    @Published var coordinate: CLLocationCoordinate2D?

    // Dependencies
    let loc: MiniLocationManager

    private var cancellables = Set<AnyCancellable>()

    init(loc: MiniLocationManager = MiniLocationManager()) {
        self.loc = loc

        // Mirror coordinate & recompute when it changes
        loc.$coordinate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coord in
                self?.coordinate = coord
                self?.recompute()
            }
            .store(in: &cancellables)
    }

    // MARK: - Lifecycle
    func onAppear() {
        loc.request()
        if coordinate != nil { recompute() }
    }

    func onDisappear() {
        // Keep for future cleanup if needed
    }

    // MARK: - UI helpers (moved from View)
    func dateString(_ format: String) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = format
        return f.string(from: Date())
    }

    func hapticLight() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    // MARK: - User actions
    func togglePrayer(at index: Int) {
        guard prayers.indices.contains(index) else { return }
        prayers[index].done.toggle()
        hapticLight()
    }

    // MARK: - Logic
    private func recompute(date: Date = Date()) {
        guard let coord = coordinate else { return }
        prayers = computePrayerItems(for: coord, date: date)
    }
}

//
//  TravelModeRow.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 29/10/2025.
//

import SwiftUI

struct TravelModeRows: View {
    @AppStorage("travel_mode_enabled") private var travelModeEnabled = false

    var body: some View {
        VStack(spacing: 0) {
            ToggleRow(icon: "airplane", title: "Travel mode", isOn: $travelModeEnabled)
        }
        .accessibilityIdentifier("travel_mode_rows")
    }
}


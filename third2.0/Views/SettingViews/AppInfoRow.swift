//
//  AppInfoRow.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct AppInfoRow: View {
    private var version: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "—"
    }
    private var build: String {
        (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "—"
    }

    var body: some View {
        Text("Version \(version) (\(build))")
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundColor(.textSecondaryLight.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
    }
}

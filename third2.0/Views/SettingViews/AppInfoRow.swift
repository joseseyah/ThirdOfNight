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
        Row(icon: "info.circle", title: "Version", trailing: {
            Text("\(version) (\(build))")
                .foregroundStyle(Color.textSecondary)
                .font(.system(size: 15, weight: .medium, design: .rounded))
        })
    }
}

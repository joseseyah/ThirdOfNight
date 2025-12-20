//
//  WatchRows.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//

import SwiftUI

struct WatchRows: View {
    @AppStorage("watch_enabled") private var watchEnabled = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Tappable area for icon and title
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentPurple.opacity(0.15))
                            .frame(width: 34, height: 34)
                        Image(systemName: "applewatch")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.accentPurple)
                    }

                    Text("Apple Watch")
                        .foregroundStyle(Color.textPrimary)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap?()
                }

                Spacer(minLength: 12)

                Toggle("", isOn: $watchEnabled)
                    .labelsHidden()
                    .tint(.accentPurple)
            }
            .padding(.vertical, 10)
        }
        .accessibilityIdentifier("watch_rows")
    }
}


//
//  LocationHeader.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import SwiftUI

struct LocationHeader: View {
    @ObservedObject var loc: MiniLocationManager

    var body: some View {
        Text(loc.placeName.isEmpty ? "Current Location" : loc.placeName)
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundColor(.accentPurple)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.accentPurple.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(Color.accentPurple.opacity(0.4), lineWidth: 1)
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: loc.placeName)
    }
}



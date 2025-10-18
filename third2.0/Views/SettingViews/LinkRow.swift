//
//  LinkRow.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct LinkRow: View {
    let icon: String
    let title: String
    let url: URL

    var body: some View {
        Row(icon: icon, title: title, trailing: {
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.textSecondary)
                .font(.system(size: 14, weight: .semibold))
        })
        .onTapGesture { UIApplication.shared.open(url) }
    }
}

//
//  ToggleRow.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Row(icon: icon, title: title, trailing: {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.accentPurple)
        })
    }
}

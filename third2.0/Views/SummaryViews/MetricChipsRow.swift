//
//  MetricChipsRow.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/10/2025.
//
import SwiftUI

struct MetricChipsRow: View {

    let chips: [ChipData]
    var spacing: CGFloat = 12
    var height: CGFloat = 92

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(chips) { c in
                MetricChip(title: c.title, value: c.value, subtitle: c.subtitle)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}


//
//  GroupSeparator.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import SwiftUI

struct GroupSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color.stroke)
            .frame(height: 1)
            .padding(.leading, 72)   // aligns under text, not under icon
            .padding(.trailing, 12)
    }
}

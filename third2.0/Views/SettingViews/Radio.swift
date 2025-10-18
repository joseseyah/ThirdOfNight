//
//  Radio.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct Radio: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            Circle().stroke(Color.stroke, lineWidth: 1).frame(width: 22, height: 22)
            if isSelected {
                Circle().fill(Color.accentYellow).frame(width: 10, height: 10)
            }
        }
    }
}

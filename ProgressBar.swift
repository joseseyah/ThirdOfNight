//
//  ProgressBar.swift
//  third
//
//  Created by Joseph Hayes on 29/03/2024.
//

import Foundation

import SwiftUI

struct ProgressBar: View {
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(red: 229/255, green: 204/255, blue: 153/255)) // Progress bar color
                    .frame(width: geometry.size.width, height: 10)
                    .cornerRadius(5.0)
                Rectangle()
                    .foregroundColor(Color(red: 0/255, green: 102/255, blue: 204/255)) // Progress color
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: 10)
                    .cornerRadius(5.0)
            }
        }
        .frame(height: 10)
    }
}



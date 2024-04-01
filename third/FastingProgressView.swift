//
//  FastingProgressView.swift
//  third
//
//  Created by Joseph Hayes on 31/03/2024.
//

import Foundation
import SwiftUI

struct FastingProgressView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Time Left till Iftar")
                    .font(.caption)
                    .foregroundColor(Color(red: 0/255, green: 121/255, blue: 153/255)) // Same color as Islamic date
                    .padding(.leading, 20)
                Spacer()
            }

            // Progress bar with custom styling
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(red: 0/255, green: 121/255, blue: 153/255)) // Same color as Islamic date
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(width: CGFloat(progress) * 150, height: 10) // Adjust width based on progress
            }
            .frame(height: 10)
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}



//
//  EatingProgressView.swift
//  third
//
//  Created by Joseph Hayes on 02/04/2024.
//

import Foundation

import SwiftUI

struct EatingProgressView: View {
    let progress: Double
    let remainingTime: String

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Progress Left till Fajr")
                    .font(.caption)
                    .foregroundColor(Color(red: 0/255, green: 121/255, blue: 153/255))
                    .padding(.leading, 20)
                Spacer()
                Text("Time Left: \(remainingTime)")
                    .font(.caption)
                    .foregroundColor(Color(red: 0/255, green: 121/255, blue: 153/255))
                    .padding(.trailing, 20)
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(red: 0/255, green: 121/255, blue: 153/255))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
//                    .frame(width: CGFloat(progress) * 150, height: 10)
                    .frame(width: CGFloat(progress * getScreenBounds().width), height: 10) // Adjust width based on progress
            }
            .frame(height: 10)
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

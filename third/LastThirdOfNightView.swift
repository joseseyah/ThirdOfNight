//  LastThirdOfNightView.swift
//  third
//
//  Created by Joseph Hayes on 07/04/2024.
//

import SwiftUI

struct LastThirdOfNightView: View {
    @Binding var lastThirdTime: String
    @State private var isShowing = false // State variable to toggle animation

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Last Third of Night")
                    .font(.caption)
                    .foregroundColor(Color(red: 0/255, green: 121/255, blue: 153/255))
                    .padding(.leading, 20)
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(height: 70)
                .overlay(
                    Text(lastThirdTime)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.black)
                )
                .padding(.horizontal, 20)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                .scaleEffect(isShowing ? 1.0 : 0.5)
                .onAppear {
                    withAnimation(.spring()) { // Apply spring animation effect
                        self.isShowing = true // Toggle animation when view appears
                    }
                }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color(red: 204/255, green: 229/255, blue: 255/255))
        .cornerRadius(15)
    }
}

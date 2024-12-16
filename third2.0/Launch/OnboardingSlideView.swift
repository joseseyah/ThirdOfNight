//
//  OnboardingSlideView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/12/2024.
//

import Foundation
import SwiftUI

struct OnboardingSlideView: View {
    let title: String
    let description: String
    let imageName: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

//
//  OnboardingSlide.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/12/2024.
//

import Foundation

import SwiftUI

// Data model for slides
struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String // For slide illustration
}

// Sample slides
let slides = [
    OnboardingSlide(title: "Welcome", description: "Your guide for seamless night prayers and more.", imageName: "moon.stars.fill"),
    OnboardingSlide(title: "Accurate Prayer Times", description: "Stay on track with precise times tailored to your location.", imageName: "clock.fill"),
    OnboardingSlide(title: "Night & Day Modes", description: "Switch effortlessly between night and day themes.", imageName: "sun.and.horizon.fill"),
    OnboardingSlide(title: "Quran Listening", description: "Listen to your favorite Surahs anytime.", imageName: "music.note.list"),
    OnboardingSlide(title: "Travel Features", description: "Plan trips and track journeys with ease.", imageName: "airplane"),
]

// Slide view
struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: slide.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundColor(.blue)
            
            Text(slide.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(slide.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}


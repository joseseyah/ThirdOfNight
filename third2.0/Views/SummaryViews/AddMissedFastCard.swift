//
//  AddMissedFastCard.swift
//  Night Prayers
//
//  Card component for adding missed fasts
//

import SwiftUI

struct AddMissedFastCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Missed Fast")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Text("Record a fast you missed")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.accentPurple.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.accentPurple)
                }
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.cardBg, Color.cardBg.opacity(0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Decorative shapes
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.accentPurple.opacity(0.1),
                                    Color.clear
                                ],
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.stroke.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(AddMissedFastButtonStyle())
    }
}

struct AddMissedFastButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.appBg.ignoresSafeArea()
        
        AddMissedFastCard {
            print("Add Missed Fast tapped")
        }
        .padding()
    }
}


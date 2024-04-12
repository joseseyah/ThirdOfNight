import SwiftUI

struct LastThirdOfNightView: View {
    var lastThirdTime: String // Change to regular property

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Last Third of Night")
                    .font(.caption)
                    .foregroundColor(Color.white) // Changed text color to white
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
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(
            VStack {
                Spacer()
                AnimatedMountainView()
            }
        )
        .cornerRadius(15)
    }
}


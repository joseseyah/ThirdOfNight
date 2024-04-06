import SwiftUI

struct AllahIcon: View {
    var body: some View {
        Text("الله")
            .font(.system(size: 15))
            .foregroundColor(.white)
            .padding(8)
            .background(Color.blue) // Change color as needed
            .clipShape(Circle())
    }
}

struct FloatingNavBar: View {
    var prayerGuidanceAction: () -> Void
    var namesOfAllahAction: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                prayerGuidanceAction()
            }) {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 0, y: 3)
            }

            Button(action: {
                namesOfAllahAction()
            }) {
                AllahIcon()
            }

        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Blur(style: .systemThinMaterial))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

struct Blur: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

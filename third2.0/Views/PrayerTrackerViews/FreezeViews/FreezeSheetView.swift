import SwiftUI

struct FreezeSheetView: View {
    @Binding var isOn: Bool

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.accentPurple.opacity(0.4))
                .frame(width: 44, height: 5)
                .padding(.top, 8)

            Text("Menstruation Freeze")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, 20)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentPurple.opacity(0.25), Color.accentPurple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Circle()
                    .stroke(Color.accentPurple.opacity(0.6), lineWidth: 2)
                Circle()
                    .stroke(Color.accentPurple.opacity(0.8), lineWidth: 3)
                    .blur(radius: 2)
                    .padding(8)

                Image(systemName: "snowflake")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.accentPurple)
                    .shadow(color: Color.accentPurple.opacity(0.5), radius: 14, x: 0, y: 4)
            }
            .frame(width: 120, height: 120)
            .padding(.top, 6)
            .overlay(
                Circle()
                    .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
            )

            Text("Use freeze when menstruating to pause prayer tracking so your streaks stay intact. You can turn it off anytime.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 22)

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            ZStack {
                Color.cardBg
                LinearGradient(
                    colors: [Color.accentPurple.opacity(0.08), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(
                    LinearGradient(
                        colors: [Color.accentPurple.opacity(0.3), Color.accentPurple.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
                .ignoresSafeArea(edges: .top)
        )
        .presentationDetents([.fraction(0.55), .large])
        .presentationDragIndicator(.hidden)
    }
}

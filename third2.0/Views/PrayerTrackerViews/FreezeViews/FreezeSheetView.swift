import SwiftUI

struct FreezeSheetView: View {
    @Binding var isOn: Bool

    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.stroke)
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
                    .fill(Color.white.opacity(0.04))
                Circle()
                    .stroke(Color.stroke, lineWidth: 1.2)
                Circle()
                    .stroke(Color.accentYellow.opacity(0.55), lineWidth: 3)
                    .blur(radius: 0.5)
                    .padding(8)

                Image(systemName: "snowflake")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.accentYellow)
                    .shadow(color: Color.accentYellow.opacity(0.28), radius: 10)
            }
            .frame(width: 120, height: 120)
            .padding(.top, 6)

            Text("Use freeze when menstruating to pause prayer tracking so your streaks stay intact. You can turn it off anytime.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 22)

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cardBg.ignoresSafeArea())
        .presentationDetents([.fraction(0.55), .large])
        .presentationDragIndicator(.hidden)
    }
}

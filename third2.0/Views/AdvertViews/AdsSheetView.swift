import SwiftUI
import StoreKit
import GoogleMobileAds

struct AdsSheetView: View {
    @StateObject private var store = StoreKitManager.shared
    @State private var selectedID: String?          // for gold highlight
    @State private var isPurchasing = false

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(spacing: 0) {
            // Grab handle
            Capsule()
                .fill(Color.stroke)
                .frame(width: 44, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 18) {
                    // Title
                    Text("Thanks for supporting the app")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // Subtitle
                    Text("Choose a support option below. You’ll see Apple’s secure payment sheet, then your purchase unlocks instantly.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // Cards
                    LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                        SupportOptionCard(
                            id: StoreKitManager.IDs.oneOff,
                            title: "One-Off Tip",
                            priceText: store.oneOff?.displayPrice ?? "£5.99",
                            badge: "One-time",
                            blurb: "Pay once to support Night Prayers.",
                            isSelected: selectedID == StoreKitManager.IDs.oneOff
                        ) {
                            guard let p = store.oneOff, !isPurchasing else { return }
                            selectAndBuy(id: p.id) { Task { await store.buy(p) } }
                        }

                        SupportOptionCard(
                            id: StoreKitManager.IDs.monthly,
                            title: "Monthly",
                            priceText: store.monthly?.displayPrice ?? "£1.99",
                            badge: "Subscription",
                            blurb: "Auto-renewing monthly support.",
                            isSelected: selectedID == StoreKitManager.IDs.monthly
                        ) {
                            guard let p = store.monthly, !isPurchasing else { return }
                            selectAndBuy(id: p.id) { Task { await store.buy(p) } }
                        }
                    }
                    .padding(.horizontal, 16)

                    if store.isActiveSubscriber {
                        Text("Thanks! You’re an active supporter 🎉")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .padding(.top, 2)
                    }

                    // Manage / Restore row (wraps nicely on small widths)
                    HStack(spacing: 18) {
                        Button("Restore Purchases") { Task { await store.restore() } }
                        Button("Manage Subscription") { store.openManageSubscriptions() }
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 16)

                    // Banner
                    BannerAdController(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                        .frame(height: 60)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                }
                .padding(.bottom, 8)
            }

            // Error surface
            if let err = store.lastError {
                Text(err)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(Color.appBg)
        .task { await store.loadProducts() }
    }

    private func selectAndBuy(id: String, purchase: @escaping () -> Void) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            selectedID = id
            isPurchasing = true
        }
        purchase()
        // Let the highlight linger briefly; StoreKit sheet will cover the UI anyway.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.25)) {
                isPurchasing = false
            }
        }
    }
}

// MARK: - Card

private struct SupportOptionCard: View {
    let id: String
    let title: String
    let priceText: String
    let badge: String
    let blurb: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // Badge
                Text(badge)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.stroke.opacity(0.25))
                    .clipShape(Capsule())
                    .foregroundColor(.textSecondary)

                // Title
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                // Price
                Text(priceText)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // Blurb
                Text(blurb)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(cardBackground)
            .overlay(cardBorder)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: isSelected ? Color.accentYellow.opacity(0.45) : .clear,
                    radius: isSelected ? 18 : 0, x: 0, y: 0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var cardBorder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.stroke, lineWidth: 1)

            if isSelected {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [Color.accentYellow.opacity(0.95),
                                                Color.accentYellow.opacity(0.55)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                    )
            }
        }
    }



    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.cardBg)

            if isSelected {
                // subtle inner gold rim
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.accentYellow.opacity(0.25), lineWidth: 8)
                    .blur(radius: 10)
            }
        }
    }
}

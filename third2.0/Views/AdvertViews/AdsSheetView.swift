import SwiftUI
import StoreKit
import GoogleMobileAds

struct AdsSheetView: View {
    @StateObject private var store = StoreKitManager.shared
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var selectedID: String?          // for gold highlight
    @State private var isPurchasing = false
    
    // Get user email from authentication manager
    private var userEmail: String? {
        authManager.user?.email
    }

    var body: some View {
        VStack(spacing: 0) {
            // Grab handle
            Capsule()
                .fill(Color.stroke)
                .frame(width: 44, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 24) {
                    // Header - Moon Icon Only
                    Image("moon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentMoon)
                        .shadow(color: .accentMoon.opacity(0.25), radius: 12, x: 0, y: 0)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                    // Monthly Plan (Top - Highlighted)
                    MonthlyPlanCard(
                        id: StoreKitManager.IDs.monthly,
                        priceText: store.monthly?.displayPrice ?? "£2.99",
                        isSelected: selectedID == StoreKitManager.IDs.monthly
                    ) {
                        guard let p = store.monthly, !isPurchasing else { return }
                        selectAndBuy(id: p.id) { Task { await store.buy(p) } }
                    }
                    .padding(.horizontal, 16)

                    // One-Off Plan (Bottom)
                    OneOffPlanCard(
                        id: StoreKitManager.IDs.oneOff,
                        priceText: store.oneOff?.displayPrice ?? "£5.99",
                        isSelected: selectedID == StoreKitManager.IDs.oneOff
                    ) {
                        guard let p = store.oneOff, !isPurchasing else { return }
                        selectAndBuy(id: p.id) { Task { await store.buy(p) } }
                    }
                    .padding(.horizontal, 16)

                    if store.isActiveSubscriber {
                        Text("Thanks! You're an active supporter 🎉")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.accentMoon)
                            .padding(.top, 4)
                    }

                    // Manage / Restore row
                    HStack(spacing: 18) {
                        Button("Restore Purchases") { Task { await store.restore() } }
                        Button("Manage Subscription") { store.openManageSubscriptions() }
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 16)

                    // Rokt Offers Section
                    //needs approval from Rokt first
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Special Offers")
//                            .font(.system(size: 16, weight: .semibold, design: .rounded))
//                            .foregroundColor(.textPrimary)
//                            .padding(.horizontal, 16)
//                        
//                        RoktOffersContainer(userEmail: userEmail)
//                    }
//                    .padding(.top, 8)
                    
                    // Banner
                    BannerAdController(adUnitID: "ca-app-pub-2760408664614132/9643788748")
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

// MARK: - Monthly Plan Card (Top - Highlighted)

private struct MonthlyPlanCard: View {
    let id: String
    let priceText: String
    let isSelected: Bool
    let action: () -> Void
    
    private let benefits = [
        "Support Third of the Night to grow",
        "Help others access prayer times",
        "Portion donated to charity",
        "Auto-renewing monthly support"
    ]

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with badge
                HStack {
                    Text("Monthly")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // PREFERRED badge
                    Text("PREFERRED")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.accentGold)
                        .foregroundColor(.appBg)
                        .clipShape(Capsule())
                        .shadow(color: Color.accentGold.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                
                // Price
                Text(priceText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                // Benefits list
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(benefits, id: \.self) { benefit in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.accentGold)
                                .padding(.top, 2)
                            
                            Text(benefit)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                // Subscribe button
                HStack {
                    Spacer()
                    Text("Subscribe to Monthly")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.appBg)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.accentGold, Color.accentGold.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.accentGold.opacity(0.3), radius: 6, x: 0, y: 3)
                .padding(.top, 4)
                
                // Legal text
                Text("By subscribing, you agree to Third of the Night's Terms of Use. Your App Store Apple ID will be charged \(priceText) per month. Automatically renews until cancelled.")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(2)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .overlay(cardBorder)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: isSelected ? Color.accentGold.opacity(0.4) : Color.black.opacity(0.2),
                    radius: isSelected ? 16 : 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [Color.accentGold.opacity(0.8), Color.accentGold.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2.5
            )
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.cardBg, Color.cardBg.opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.accentGold.opacity(0.12), Color.accentGold.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

// MARK: - One-Off Plan Card (Bottom)

private struct OneOffPlanCard: View {
    let id: String
    let priceText: String
    let isSelected: Bool
    let action: () -> Void
    
    private let benefits = [
        "Support Third of the Night to grow",
        "Help others access prayer times",
        "Portion donated to charity",
        "One-time payment"
    ]

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with badge
                HStack {
                    Text("One-Off Tip")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    // One-time badge
                    Text("ONE-TIME")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.stroke.opacity(0.3))
                        .foregroundColor(.textSecondary)
                        .clipShape(Capsule())
                }
                
                // Price
                Text(priceText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                // Benefits list
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(benefits, id: \.self) { benefit in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .padding(.top, 2)
                            
                            Text(benefit)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                // Subscribe button
                HStack {
                    Spacer()
                    Text("Make One-Time Payment")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.buttonText)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color.accentPurple)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.stroke, lineWidth: 1)
                )
                .padding(.top, 4)
                
                // Legal text
                Text("By making a payment, you agree to Third of the Night's Terms of Use. Your App Store Apple ID will be charged \(priceText) once.")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .lineSpacing(2)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.cardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.stroke.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

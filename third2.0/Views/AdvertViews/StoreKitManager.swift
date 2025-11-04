//
//  StoreKitManager.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 04/11/2025.
//


import StoreKit
import SwiftUI

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    enum IDs {
        static let oneOff = "support_oneoff_599"
        static let monthly = "support_monthly_199"
    }

    @Published var oneOff: Product?
    @Published var monthly: Product?
    @Published var isActiveSubscriber: Bool = false
    @Published var isLoading = false
    @Published var lastError: String?

    init() {
        // Start transaction listener as soon as possible
        Task { await listenForTransactions() }
        Task { await refreshEntitlements() }
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [IDs.oneOff, IDs.monthly])
            for p in products {
                if p.id == IDs.oneOff { oneOff = p }
                if p.id == IDs.monthly { monthly = p }
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func buy(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            do {
                let transaction = try checkVerified(update)
                await transaction.finish()
                await refreshEntitlements()
            } catch {
                // ignore invalid transactions
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let signedType):
            return signedType
        }
    }

    func refreshEntitlements() async {
        var hasActiveSub = false

        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let txn: StoreKit.Transaction = try checkVerified(result)
                if txn.productID == IDs.monthly,
                   txn.revocationDate == nil,
                   (txn.expirationDate == nil || txn.expirationDate! > Date())
                {
                    hasActiveSub = true
                    break
                }
            } catch {
                // ignore unverified entries
            }
        }

        self.isActiveSubscriber = hasActiveSub
    }



    func openManageSubscriptions() {
        // Native manage sheet (iOS 15+)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            Task { try? await AppStore.showManageSubscriptions(in: scene) }
        }
    }
}

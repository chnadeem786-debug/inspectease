//
//  Entitlements.swift
//  InspectEase
//
//  Pro subscription state using StoreKit, ported from BillingHelper and the
//  premium state in InspectionViewModel in the Android app.
//

import Foundation
import Observation
import StoreKit
import FirebaseAuth

@MainActor
@Observable
final class Entitlements {
    static let shared = Entitlements()

    /// Must match the auto-renewing subscription product created in App Store Connect.
    static let productID = "pro_plan"

    private(set) var isPremium = false
    private(set) var product: Product?
    private(set) var isLoading = false

    private var transactionTask: Task<Void, Never>?

    private init() {
        transactionTask = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await refresh()
            }
        }
        Task { await refresh() }
    }

    func loadProduct() async {
        do {
            product = try await Product.products(for: [Self.productID]).first
        } catch {
            product = nil
        }
    }

    func refresh() async {
        isLoading = true
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                active = true
            }
        }
        isPremium = active
        isLoading = false
    }

    /// Returns true when the purchase went through.
    func purchase() async throws -> Bool {
        guard let product else { return false }
        let result = try await product.purchase()
        guard case .success(let verification) = result,
              case .verified(let transaction) = verification else {
            return false
        }
        await transaction.finish()
        await refresh()
        await syncToCloud()
        return isPremium
    }

    func restore() async throws {
        try await AppStore.sync()
        await refresh()
        await syncToCloud()
    }

    private func syncToCloud() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        try? await CloudService.updateSubscription(
            userId: userId,
            isPremium: isPremium,
            productId: Self.productID
        )
    }
}

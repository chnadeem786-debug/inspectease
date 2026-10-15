//
//  SubscriptionView.swift
//  InspectEase
//
//  Pro subscription screen, ported from SubscriptionScreenColorful in the
//  Android app.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @State private var isBusy = false
    @State private var alertMessage: String?

    private var entitlements: Entitlements { Entitlements.shared }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(entitlements.isPremium ? "You are a Pro user! ✨" : "Unlock everything and inspect with ease.")
                    .font(.body)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 16) {
                    BenefitRow(text: "Unlimited Inspections")
                    BenefitRow(text: "Professional PDF Reports")
                    BenefitRow(text: "High-Quality Photo Storage")
                    BenefitRow(text: "Custom Branding")
                    BenefitRow(text: "Priority Support")
                }

                TierCard(
                    title: "Monthly Pro",
                    price: entitlements.product?.displayPrice ?? "—",
                    period: "/ month"
                )

                if entitlements.isPremium {
                    Text("✓ Premium Active")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(ModernColorfulTheme.success, in: RoundedRectangle(cornerRadius: 12))
                } else {
                    Button(action: subscribe) {
                        Text("Subscribe Now ✨")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(ModernColorfulTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(isBusy || entitlements.product == nil)
                }

                Button("Restore Purchases", action: restore)
                    .font(.subheadline)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
                    .disabled(isBusy)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("InspectEase Pro")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await entitlements.loadProduct()
        }
        .alert("InspectEase", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func subscribe() {
        isBusy = true
        Task {
            defer { isBusy = false }
            do {
                let success = try await entitlements.purchase()
                if !success {
                    alertMessage = "The purchase did not complete."
                }
            } catch {
                alertMessage = "Purchase failed: \(error.localizedDescription)"
            }
        }
    }

    private func restore() {
        isBusy = true
        Task {
            defer { isBusy = false }
            do {
                try await entitlements.restore()
                alertMessage = entitlements.isPremium
                    ? "Your Pro subscription has been restored."
                    : "No previous purchases were found."
            } catch {
                alertMessage = "Restore failed: \(error.localizedDescription)"
            }
        }
    }
}

private struct BenefitRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text("✨")
                .font(.title3)
            Text(text)
                .font(.body)
                .foregroundStyle(ModernColorfulTheme.textPrimary)
        }
    }
}

private struct TierCard: View {
    let title: String
    let price: String
    let period: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(ModernColorfulTheme.textPrimary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(price)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(ModernColorfulTheme.primary)
                Text(period)
                    .font(.subheadline)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ModernColorfulTheme.primary, lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        SubscriptionView()
    }
}

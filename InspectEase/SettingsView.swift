//
//  SettingsView.swift
//  InspectEase
//
//  Settings menu, ported from SettingsScreenColorful in the Android app.
//

import SwiftUI

struct SettingsView: View {
    @State private var showNotificationsNotice = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                SettingsRow(
                    title: "Subscription",
                    subtitle: Entitlements.shared.isPremium ? "Premium Active" : "Upgrade to Pro",
                    route: .subscription
                )
                SettingsRow(title: "Account", subtitle: "Manage your account", route: .account)

                Button {
                    showNotificationsNotice = true
                } label: {
                    SettingsRowLabel(title: "Notifications", subtitle: "Notification settings")
                }
                .buttonStyle(.plain)

                SettingsRow(title: "Privacy", subtitle: "Privacy settings & policy", route: .privacy)
                SettingsRow(title: "About", subtitle: "About InspectEase", route: .about)

                Button {
                    try? AuthService.shared.signOut()
                } label: {
                    SettingsRowLabel(title: "Logout", subtitle: "Sign out of your account")
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("InspectEase", isPresented: $showNotificationsNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Notifications are managed in the iPhone's Settings app.")
        }
    }
}

private struct SettingsRow: View {
    let title: String
    let subtitle: String
    let route: Route

    var body: some View {
        NavigationLink(value: route) {
            SettingsRowLabel(title: title, subtitle: subtitle)
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsRowLabel: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ModernColorfulTheme.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(ModernColorfulTheme.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

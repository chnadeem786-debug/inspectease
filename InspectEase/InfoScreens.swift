//
//  InfoScreens.swift
//  InspectEase
//
//  Account, About, and Privacy screens, ported from AccountScreenColorful,
//  AboutScreenColorful and PrivacyScreenColorful in the Android app.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @State private var showDeleteNotice = false
    @State private var alertMessage: String?

    private var email: String { Auth.auth().currentUser?.email ?? "Not Logged In" }
    private var uid: String { Auth.auth().currentUser?.uid ?? "N/A" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("👤 Profile Info")
                    .font(.subheadline.bold())
                    .foregroundStyle(ModernColorfulTheme.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email: \(email)")
                        .font(.subheadline)
                        .foregroundStyle(ModernColorfulTheme.textPrimary)
                    Text("User ID: \(uid)")
                        .font(.caption2)
                        .foregroundStyle(ModernColorfulTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 12))

                Text("⚙️ Actions")
                    .font(.subheadline.bold())
                    .foregroundStyle(ModernColorfulTheme.textPrimary)

                Button {
                    try? AuthService.shared.signOut()
                } label: {
                    Text("Logout")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(ModernColorfulTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    showDeleteNotice = true
                } label: {
                    Text("❌ Delete Account")
                        .font(.subheadline.bold())
                        .foregroundStyle(ModernColorfulTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("InspectEase", isPresented: $showDeleteNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please contact support to delete your account data.")
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🏠")
                .font(.system(size: 64))
            Text("InspectEase Pro")
                .font(.title.bold())
                .foregroundStyle(ModernColorfulTheme.primary)
            Text("Version 1.9 (Code 10)")
                .font(.subheadline)
                .foregroundStyle(ModernColorfulTheme.textSecondary)

            Text("The ultimate tool for modern home inspectors. Fast, reliable, and colorful reporting at your fingertips.")
                .font(.subheadline)
                .foregroundStyle(ModernColorfulTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Spacer()

            Text("Developed by InspectEase Team")
                .font(.caption)
                .foregroundStyle(ModernColorfulTheme.textSecondary)
            Text("© 2026 All Rights Reserved")
                .font(.caption)
                .foregroundStyle(ModernColorfulTheme.textSecondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title.bold())
                    .foregroundStyle(ModernColorfulTheme.primary)
                Text("Last Updated: August 2026")
                    .font(.caption)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)

                PrivacySection(
                    title: "1. Data Collection",
                    text: "We collect your email and inspection data (address, photos, notes) solely to provide cloud synchronization features. This data is stored securely in Google Firebase."
                )
                PrivacySection(
                    title: "2. Camera Access",
                    text: "The app requires camera access to take property photos. These photos are stored on your device and optionally uploaded to your private cloud storage."
                )
                PrivacySection(
                    title: "3. Data Security",
                    text: "Your data is protected using industry-standard encryption and Firebase security rules. We do not sell or share your personal information with third parties."
                )
                PrivacySection(
                    title: "4. Your Rights",
                    text: "You can request deletion of your account and all associated data at any time by contacting support."
                )

                Text("For full legal terms, visit our website.")
                    .font(.caption)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
                    .padding(.top, 24)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PrivacySection: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(ModernColorfulTheme.textPrimary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(ModernColorfulTheme.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyView()
    }
}

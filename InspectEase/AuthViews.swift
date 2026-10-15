//
//  AuthViews.swift
//  InspectEase
//
//  Login and sign-up screens, ported from LoginScreenColorful and
//  SignUpScreenColorful in the Android app.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var alertMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("🏠 InspectEase")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(ModernColorfulTheme.primary)
                Text("Sign in to your account")
                    .font(.subheadline)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)

                Spacer().frame(height: 24)

                AuthTextField(placeholder: "Email", text: $email, keyboard: .emailAddress)
                AuthSecureField(placeholder: "Password", text: $password)

                AuthButton(title: "Login", isLoading: isLoading, action: login)

                Button("Forgot Password?", action: resetPassword)
                    .font(.caption)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)

                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Don't have an account? Sign up")
                        .font(.subheadline)
                        .foregroundStyle(ModernColorfulTheme.primary)
                }

                Spacer().frame(height: 24)

                Text("Lost your account ID?")
                    .font(.caption2)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
                Link(destination: URL(string: "mailto:aksclassic247@gmail.com?subject=InspectEase%20Support%20Request")!) {
                    Text("Contact Support for assistance")
                        .font(.caption2.bold())
                        .foregroundStyle(ModernColorfulTheme.primary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("InspectEase", isPresented: alertBinding(for: $alertMessage)) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                try await AuthService.shared.signIn(email: email, password: password)
            } catch {
                alertMessage = error.localizedDescription
            }
        }
    }

    private func resetPassword() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email first"
            return
        }
        Task {
            do {
                try await AuthService.shared.resetPassword(email: email)
                alertMessage = "Password reset email sent to \(email)"
            } catch {
                alertMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
}

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var alertMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("🏠 InspectEase")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(ModernColorfulTheme.primary)
                Text("Create your account")
                    .font(.subheadline)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)

                Spacer().frame(height: 24)

                AuthTextField(placeholder: "Email", text: $email, keyboard: .emailAddress)
                AuthSecureField(placeholder: "Password", text: $password)

                AuthButton(title: "Sign Up", isLoading: isLoading, action: signUp)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .alert("InspectEase", isPresented: alertBinding(for: $alertMessage)) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func signUp() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                try await AuthService.shared.signUp(email: email, password: password)
            } catch {
                alertMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Helpers

private func alertBinding(for message: Binding<String?>) -> Binding<Bool> {
    Binding(
        get: { message.wrappedValue != nil },
        set: { if !$0 { message.wrappedValue = nil } }
    )
}

private struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(keyboard)
            .fieldStyle()
    }
}

private struct AuthSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .fieldStyle()
    }
}

private struct AuthButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(ModernColorfulTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}

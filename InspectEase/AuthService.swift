//
//  AuthService.swift
//  InspectEase
//
//  Email sign-in, sign-up, and password reset, ported from FirebaseHelper
//  and the auth state in InspectionViewModel in the Android app.
//

import Foundation
import FirebaseAuth
import Observation

@MainActor
@Observable
final class AuthService {
    static let shared = AuthService()

    private(set) var user: FirebaseAuth.User?
    private var listener: AuthStateDidChangeListenerHandle?

    var isLoggedIn: Bool { user != nil }

    private init() {
        user = Auth.auth().currentUser
        listener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}

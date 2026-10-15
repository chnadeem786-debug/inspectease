//
//  InspectEaseApp.swift
//  InspectEase
//
//  Created by Nadeem on 10/14/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct InspectEaseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Shows sign-in until the user is logged in, then the home screen.
struct RootView: View {
    private var auth: AuthService { AuthService.shared }

    var body: some View {
        if auth.isLoggedIn {
            ContentView()
        } else {
            NavigationStack {
                LoginView()
            }
        }
    }
}

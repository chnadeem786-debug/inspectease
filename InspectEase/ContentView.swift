//
//  ContentView.swift
//  InspectEase
//
//  Home screen, ported from HomeScreenColorful in the Android app.
//

import SwiftUI

enum Route: Hashable {
    case newInspection
    case photos
    case reports
    case settings
    case subscription
}

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 16) {
                    MenuCard(
                        emoji: "📋",
                        title: "New Inspection",
                        subtitle: "Start inspection",
                        background: Color(hex: 0xFFE5E5)
                    ) { path.append(Route.newInspection) }

                    MenuCard(
                        emoji: "📸",
                        title: "Photo Gallery",
                        subtitle: "View photos",
                        background: Color(hex: 0xFFF4E5)
                    ) { path.append(Route.photos) }

                    MenuCard(
                        emoji: "📄",
                        title: "Reports",
                        subtitle: "View reports",
                        background: Color(hex: 0xF0E5FF)
                    ) { path.append(Route.reports) }

                    MenuCard(
                        emoji: "⚙️",
                        title: "Settings",
                        subtitle: "App settings",
                        background: Color(hex: 0xE5F0FF)
                    ) { path.append(Route.settings) }

                    UpgradeBanner { path.append(Route.subscription) }
                }
                .padding(16)
            }
            .background(Color.white)
            .safeAreaInset(edge: .top, spacing: 0) {
                HeaderView()
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .newInspection:
                    NewInspectionView()
                case .photos:
                    PlaceholderView(title: "Photo Gallery")
                case .reports:
                    ReportsView(onUpgrade: { path.append(Route.subscription) })
                case .settings:
                    PlaceholderView(title: "Settings")
                case .subscription:
                    PlaceholderView(title: "Subscription")
                }
            }
        }
    }
}

private struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🏠 InspectEase")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(.white)
            Text("Modern. Colorful. Fast.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(ModernColorfulTheme.primaryGradient)
    }
}

private struct MenuCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let background: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 28))
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(ModernColorfulTheme.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(ModernColorfulTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(background, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

private struct UpgradeBanner: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upgrade to Pro")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Unlock every feature")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundStyle(.white)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(ModernColorfulTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

/// Stand-in for screens that haven't been ported yet.
struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2.bold())
            Text("Not ported yet")
                .foregroundStyle(ModernColorfulTheme.textSecondary)
        }
        .navigationTitle(title)
    }
}

#Preview {
    ContentView()
}

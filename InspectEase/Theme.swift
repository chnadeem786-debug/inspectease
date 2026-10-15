//
//  Theme.swift
//  InspectEase
//
//  Ported from ModernColorfulTheme in the Android app.
//

import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum ModernColorfulTheme {
    static let primary = Color(hex: 0xFF6B6B)
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: 0xFF6B6B), Color(hex: 0xFECA57)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let success = Color(hex: 0x4CAF50)
    static let textPrimary = Color(hex: 0x2C3E50)
    static let textSecondary = Color(hex: 0x95A5A6)
    static let lightGray = Color(hex: 0xF8F9FA)
}

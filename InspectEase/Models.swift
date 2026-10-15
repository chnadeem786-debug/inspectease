//
//  Models.swift
//  InspectEase
//
//  Ported from InspectionData and Issue in the Android app.
//

import Foundation

struct InspectionData: Equatable {
    var address = ""
    var inspectorName = ""
    var date = ""
    var photos: [String] = []
    var selectedIssues: [String] = []
    var notes = ""
    var rating = 0
}

/// Billing isn't ported yet, so every user is free for now.
enum AppStatus {
    static let isPremium = false
}

struct Issue: Identifiable, Hashable {
    let id: String
    let emoji: String
    let name: String
}

extension Issue {
    static let all: [Issue] = [
        Issue(id: "roof", emoji: "🏠", name: "Roof"),
        Issue(id: "water", emoji: "💧", name: "Water"),
        Issue(id: "electrical", emoji: "⚡", name: "Electrical"),
        Issue(id: "structural", emoji: "🔨", name: "Structural"),
        Issue(id: "HVAC", emoji: "❄️", name: "HVAC"),
        Issue(id: "plumbing", emoji: "🚿", name: "Plumbing"),
    ]
}

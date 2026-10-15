//
//  CloudService.swift
//  InspectEase
//
//  Firestore sync, ported from FirebaseHelper in the Android app.
//  Only inspection metadata is synced; photos stay on the device.
//

import Foundation
import FirebaseFirestore

enum CloudService {
    private static var db: Firestore { Firestore.firestore() }

    static func saveInspection(_ inspection: SavedInspection, userId: String) async throws {
        let data: [String: Any] = [
            "address": inspection.address,
            "inspectorName": inspection.inspectorName,
            "date": inspection.date,
            "photos": inspection.photos,
            "selectedIssues": inspection.selectedIssues,
            "notes": inspection.notes,
            "rating": inspection.rating,
            "timestamp": inspection.timestamp,
        ]
        try await db.collection("users").document(userId)
            .collection("inspections").document().setData(data)
    }

    static func fetchInspections(userId: String) async -> [SavedInspection] {
        do {
            let snapshot = try await db.collection("users").document(userId)
                .collection("inspections").getDocuments()
            return snapshot.documents.compactMap { SavedInspection(firestoreData: $0.data()) }
        } catch {
            return []
        }
    }

    /// True when the cloud record (written by the Android app or by this app) is still active.
    static func checkSubscription(userId: String) async -> Bool {
        do {
            let doc = try await db.collection("users").document(userId)
                .collection("subscriptions").document("active").getDocument()
            guard doc.exists else { return false }
            let expiresAt = (doc.data()?["expiresAt"] as? NSNumber)?.int64Value ?? 0
            return expiresAt > Int64(Date().timeIntervalSince1970 * 1000)
        } catch {
            return false
        }
    }

    static func updateSubscription(userId: String, isPremium: Bool, productId: String) async throws {
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        // Same 32-day window the Android app uses for monthly plans.
        let expiresAt = isPremium ? now + 32 * 24 * 60 * 60 * 1000 : 0
        try await db.collection("users").document(userId)
            .collection("subscriptions").document("active").setData([
                "isPremium": isPremium,
                "productId": productId,
                "updatedAt": now,
                "expiresAt": expiresAt,
            ])
    }
}

extension SavedInspection {
    init?(firestoreData data: [String: Any]) {
        guard let timestamp = (data["timestamp"] as? NSNumber)?.int64Value else { return nil }
        self.init(
            timestamp: timestamp,
            address: data["address"] as? String ?? "",
            inspectorName: data["inspectorName"] as? String ?? "",
            date: data["date"] as? String ?? "",
            photos: data["photos"] as? [String] ?? [],
            selectedIssues: data["selectedIssues"] as? [String] ?? [],
            notes: data["notes"] as? String ?? "",
            rating: (data["rating"] as? NSNumber)?.intValue ?? 0
        )
    }
}

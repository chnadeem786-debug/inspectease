//
//  InspectionDraft.swift
//  InspectEase
//
//  Holds the inspection being filled in, ported from InspectionViewModel's
//  inspection state in the Android app.
//

import Foundation
import Observation

@MainActor
@Observable
final class InspectionDraft {
    static let totalSteps = 6
    /// Free accounts can attach this many photos.
    static let freePhotoLimit = 3
    var isPremium: Bool { AppStatus.isPremium }

    var data = InspectionData()
    var step = 1

    var canAddPhoto: Bool {
        isPremium || data.photos.count < Self.freePhotoLimit
    }

    func nextStep() {
        if step < Self.totalSteps { step += 1 }
    }

    func prevStep() {
        if step > 1 { step -= 1 }
    }

    func toggleIssue(_ id: String) {
        if let index = data.selectedIssues.firstIndex(of: id) {
            data.selectedIssues.remove(at: index)
        } else {
            data.selectedIssues.append(id)
        }
    }

    func addPhoto(jpegData: Data) throws {
        let name = try InspectionStorage.savePhoto(jpegData)
        data.photos.append(name)
    }

    func removePhoto(named name: String) {
        data.photos.removeAll { $0 == name }
        InspectionStorage.deletePhoto(named: name)
    }

    /// Saves locally only. The Android app also syncs metadata to the cloud.
    func save() throws {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        try InspectionStorage.saveInspection(
            SavedInspection(
                timestamp: timestamp,
                address: data.address,
                inspectorName: data.inspectorName,
                date: data.date,
                photos: data.photos,
                selectedIssues: data.selectedIssues,
                notes: data.notes,
                rating: data.rating
            )
        )
    }
}

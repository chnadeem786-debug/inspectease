//
//  InspectionStorage.swift
//  InspectEase
//
//  Local storage for inspections and photos, ported from LocalDataManager
//  in the Android app. Cloud sync (Firestore) is not ported yet.
//

import Foundation

struct SavedInspection: Codable, Identifiable {
    /// Milliseconds since 1970, same as the Android timestamp.
    let timestamp: Int64
    let address: String
    let inspectorName: String
    let date: String
    /// File names inside the photos folder, not full paths.
    let photos: [String]
    let selectedIssues: [String]
    let notes: String
    let rating: Int

    var id: Int64 { timestamp }
}

enum InspectionStorage {
    private static var baseURL: URL {
        let url = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("InspectEase", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static var photosFolder: URL {
        let url = baseURL.appendingPathComponent("Photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static var inspectionsFile: URL {
        baseURL.appendingPathComponent("local_inspections.json")
    }

    /// Newest first.
    static func loadInspections() -> [SavedInspection] {
        guard let data = try? Data(contentsOf: inspectionsFile) else { return [] }
        return (try? JSONDecoder().decode([SavedInspection].self, from: data)) ?? []
    }

    static func saveInspection(_ inspection: SavedInspection) throws {
        var list = loadInspections()
        list.insert(inspection, at: 0)
        let data = try JSONEncoder().encode(list)
        try data.write(to: inspectionsFile, options: .atomic)
    }

    /// Writes JPEG data to the photos folder and returns the file name.
    static func savePhoto(_ jpegData: Data) throws -> String {
        let name = "photo_\(UUID().uuidString).jpg"
        try jpegData.write(to: photosFolder.appendingPathComponent(name), options: .atomic)
        return name
    }

    static func photoURL(for name: String) -> URL {
        photosFolder.appendingPathComponent(name)
    }

    static func deletePhoto(named name: String) {
        try? FileManager.default.removeItem(at: photoURL(for: name))
    }
}

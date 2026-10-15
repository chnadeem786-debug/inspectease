//
//  PhotoGalleryView.swift
//  InspectEase
//
//  Photo gallery, ported from PhotosScreenColorful in the Android app.
//

import SwiftUI
import UIKit

struct PhotoGalleryView: View {
    @State private var photos: [GalleryPhoto] = []
    @State private var alertMessage: String?

    var body: some View {
        Group {
            if photos.isEmpty {
                VStack(spacing: 16) {
                    Text("📸")
                        .font(.system(size: 48))
                    Text("No photos saved yet")
                        .font(.headline)
                        .foregroundStyle(ModernColorfulTheme.textPrimary)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(photos) { photo in
                            GalleryCard(photo: photo) {
                                delete(photo)
                            }
                        }
                    }
                    .padding(16)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationTitle("Photo Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: reload)
        .alert(
            "InspectEase",
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func reload() {
        photos = InspectionStorage.loadInspections().flatMap { inspection in
            inspection.photos.map { GalleryPhoto(name: $0, timestamp: inspection.timestamp) }
        }
    }

    private func delete(_ photo: GalleryPhoto) {
        do {
            try InspectionStorage.removePhoto(named: photo.name, fromInspection: photo.timestamp)
            reload()
        } catch {
            alertMessage = "Could not delete the photo: \(error.localizedDescription)"
        }
    }
}

private struct GalleryPhoto: Identifiable {
    let name: String
    let timestamp: Int64

    var id: String { "\(timestamp)-\(name)" }
}

private struct GalleryCard: View {
    let photo: GalleryPhoto
    let onDelete: () -> Void

    var body: some View {
        Group {
            if let image = UIImage(contentsOfFile: InspectionStorage.photoURL(for: photo.name).path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(width: 250, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .overlay(alignment: .topTrailing) {
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(.black.opacity(0.6), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(8)
        }
    }
}

#Preview {
    NavigationStack {
        PhotoGalleryView()
    }
}

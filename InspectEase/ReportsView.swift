//
//  ReportsView.swift
//  InspectEase
//
//  Reports list and inspection details, ported from ReportsScreenColorful,
//  ReportDetailsScreen and LockedFeatureScreen in the Android app.
//  PDF export ("Share PDF Report") is not ported yet.
//

import SwiftUI
import UIKit
import FirebaseAuth

struct ReportsView: View {
    var onUpgrade: () -> Void = {}

    @State private var inspections: [SavedInspection] = []

    private func loadInspections() async {
        let local = InspectionStorage.loadInspections()
        inspections = local
        guard let userId = AuthService.shared.user?.uid else { return }

        let cloud = await CloudService.fetchInspections(userId: userId)
        var seen = Set<Int64>()
        inspections = (local + cloud)
            .filter { seen.insert($0.timestamp).inserted }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        Group {
            if !Entitlements.shared.isPremium {
                LockedFeatureView(
                    title: "Professional Reports",
                    description: "Generate and share unlimited PDF reports with your own branding.",
                    action: onUpgrade
                )
            } else if inspections.isEmpty {
                VStack(spacing: 8) {
                    Text("📄")
                        .font(.system(size: 48))
                    Text("No reports saved yet")
                        .font(.headline)
                        .foregroundStyle(ModernColorfulTheme.textPrimary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(inspections) { inspection in
                            NavigationLink {
                                ReportDetailView(inspection: inspection)
                            } label: {
                                ReportCard(inspection: inspection)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadInspections()
        }
    }
}

struct ReportDetailView: View {
    let inspection: SavedInspection

    @State private var pdfURL: URL?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DetailItem(label: "📍 Address", value: inspection.address.isEmpty ? "N/A" : inspection.address)
                DetailItem(label: "👤 Inspector", value: inspection.inspectorName.isEmpty ? "N/A" : inspection.inspectorName)
                DetailItem(label: "📅 Date", value: inspection.date.isEmpty ? "N/A" : inspection.date)

                if !inspection.photos.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📸 Photos")
                            .font(.subheadline.bold())
                            .foregroundStyle(ModernColorfulTheme.textPrimary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(inspection.photos, id: \.self) { name in
                                    if let image = UIImage(contentsOfFile: InspectionStorage.photoURL(for: name).path) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                }

                DetailItem(label: "📝 Notes", value: inspection.notes.isEmpty ? "No notes added" : inspection.notes)

                VStack(alignment: .leading, spacing: 8) {
                    Text("⭐ Rating")
                        .font(.subheadline.bold())
                        .foregroundStyle(ModernColorfulTheme.textPrimary)
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { value in
                            Image(systemName: value <= inspection.rating ? "star.fill" : "star")
                                .font(.system(size: 24))
                                .foregroundStyle(value <= inspection.rating ? Color(hex: 0xFFC107) : Color.gray.opacity(0.4))
                        }
                    }
                }

                if let pdfURL {
                    ShareLink(item: pdfURL) {
                        Text("📩 Share PDF Report")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(ModernColorfulTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Inspection Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            pdfURL = try? PDFReport.generate(for: inspection)
        }
    }
}

private struct ReportCard: View {
    let inspection: SavedInspection

    var body: some View {
        HStack(spacing: 16) {
            thumbnail

            VStack(alignment: .leading, spacing: 2) {
                Text(inspection.address.isEmpty ? "Unknown Address" : inspection.address)
                    .font(.subheadline.bold())
                    .foregroundStyle(ModernColorfulTheme.textPrimary)
                Text(inspection.date.isEmpty ? "No Date" : inspection.date)
                    .font(.caption)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(ModernColorfulTheme.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let first = inspection.photos.first,
           let image = UIImage(contentsOfFile: InspectionStorage.photoURL(for: first).path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Text("🏠")
                .font(.system(size: 28))
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline.bold())
                .foregroundStyle(ModernColorfulTheme.textPrimary)
            Text(value)
                .font(.body)
                .foregroundStyle(ModernColorfulTheme.textSecondary)
        }
    }
}

private struct LockedFeatureView: View {
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("🔒")
                .font(.system(size: 64))
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(ModernColorfulTheme.textPrimary)
                .multilineTextAlignment(.center)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(ModernColorfulTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: action) {
                Text("Unlock with Pro ✨")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(ModernColorfulTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        ReportsView()
    }
}

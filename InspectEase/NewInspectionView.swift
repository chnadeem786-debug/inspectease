//
//  NewInspectionView.swift
//  InspectEase
//
//  Six-step inspection form, ported from InspectionScreenColorful in the
//  Android app.
//

import SwiftUI
import PhotosUI
import UIKit
import FirebaseAuth

struct NewInspectionView: View {
    @State private var draft = InspectionDraft()
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var alertMessage: String?
    @State private var showDatePicker = false
    @State private var showCamera = false
    @State private var selectedDate = Date()
    @Environment(\.dismiss) private var dismiss

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            StepProgress(step: draft.step, total: InspectionDraft.totalSteps)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    stepContent
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(spacing: 12) {
                PrimaryButton(
                    title: draft.step < InspectionDraft.totalSteps ? "Next →" : "✓ Save Inspection",
                    action: primaryAction
                )
                if draft.step > 1 {
                    SecondaryButton(title: "← Back") { draft.prevStep() }
                }
            }
            .padding(16)
        }
        .navigationTitle("New Inspection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(draft.step > 1)
        .toolbar {
            if draft.step > 1 {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        draft.prevStep()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
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
        .onChange(of: pickerItems) { _, items in
            guard !items.isEmpty else { return }
            Task { await loadPhotos(items) }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                showCamera = false
                if let image {
                    addCapturedPhoto(image)
                }
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch draft.step {
        case 1: propertyDetails
        case 2: photosStep
        case 3: issuesStep
        case 4: notesStep
        case 5: ratingStep
        default: reviewStep
        }
    }

    // MARK: - Steps

    private var propertyDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("📍 Property Details")

            TextField("Enter property address", text: $draft.data.address)
                .textFieldStyle(.plain)
                .fieldStyle()

            TextField("Inspector Name", text: $draft.data.inspectorName)
                .textFieldStyle(.plain)
                .fieldStyle()

            Button {
                showDatePicker = true
            } label: {
                HStack {
                    Text(draft.data.date.isEmpty ? "Select date" : draft.data.date)
                        .foregroundStyle(draft.data.date.isEmpty
                            ? ModernColorfulTheme.textSecondary
                            : ModernColorfulTheme.textPrimary)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundStyle(ModernColorfulTheme.textSecondary)
                }
                .fieldStyle()
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                        .navigationTitle("Inspection Date")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    draft.data.date = Self.dateFormatter.string(from: selectedDate)
                                    showDatePicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var photosStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("📸 Property Photos")

            if !draft.data.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(draft.data.photos, id: \.self) { name in
                            PhotoThumbnail(url: InspectionStorage.photoURL(for: name)) {
                                draft.removePhoto(named: name)
                            }
                        }
                    }
                }
                Text("\(draft.data.photos.count) photos")
                    .font(.caption)
                    .foregroundStyle(ModernColorfulTheme.textSecondary)
            }

            HStack(spacing: 8) {
                Button {
                    showCamera = true
                } label: {
                    Text("📷 Snap")
                        .font(.subheadline.bold())
                        .foregroundStyle(ModernColorfulTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(!draft.canAddPhoto || !CameraPicker.isAvailable)

                PhotosPicker(
                    selection: $pickerItems,
                    maxSelectionCount: remainingPhotoSlots,
                    matching: .images
                ) {
                    Text("📁 Upload")
                        .font(.subheadline.bold())
                        .foregroundStyle(ModernColorfulTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!draft.canAddPhoto)
            }

            if !draft.canAddPhoto {
                Text("Free limit reached (\(InspectionDraft.freePhotoLimit) photos). Go Pro for unlimited.")
                    .font(.caption.bold())
                    .foregroundStyle(ModernColorfulTheme.primary)
            }
        }
    }

    private var issuesStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("🔍 Issues Found")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Issue.all) { issue in
                    IssueCard(
                        issue: issue,
                        isSelected: draft.data.selectedIssues.contains(issue.id)
                    ) {
                        draft.toggleIssue(issue.id)
                    }
                }
            }
        }
    }

    private var notesStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("📝 Detailed Notes")

            TextField("Describe what you found...", text: $draft.data.notes, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(5, reservesSpace: true)
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var ratingStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("⭐ Property Condition")

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        draft.data.rating = value
                    } label: {
                        Image(systemName: value <= draft.data.rating ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundStyle(value <= draft.data.rating ? Color(hex: 0xFFC107) : Color.gray.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("✅ Review & Save")

            VStack(alignment: .leading, spacing: 8) {
                Text("Address: \(draft.data.address)")
                Text("Inspector: \(draft.data.inspectorName)")
                Text("Date: \(draft.data.date)")
                Text("Photos: \(draft.data.photos.count)")
                Text("Issues: \(draft.data.selectedIssues.count)")
                Text("Rating: \(draft.data.rating)/5")
            }
            .font(.subheadline)
            .foregroundStyle(ModernColorfulTheme.textPrimary)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Actions

    private var remainingPhotoSlots: Int {
        if draft.isPremium { return 10 }
        return max(1, InspectionDraft.freePhotoLimit - draft.data.photos.count)
    }

    private func primaryAction() {
        if draft.step < InspectionDraft.totalSteps {
            if draft.step == 1 && (draft.data.address.isEmpty || draft.data.inspectorName.isEmpty) {
                alertMessage = "Please fill required fields"
            } else {
                draft.nextStep()
            }
        } else {
            do {
                let saved = try draft.save()
                syncToCloud(saved)
                dismiss()
            } catch {
                alertMessage = "Could not save the inspection: \(error.localizedDescription)"
            }
        }
    }

    /// Best-effort metadata sync. The local copy is the primary record.
    private func syncToCloud(_ inspection: SavedInspection) {
        guard let userId = AuthService.shared.user?.uid else { return }
        Task { try? await CloudService.saveInspection(inspection, userId: userId) }
    }

    private func addCapturedPhoto(_ image: UIImage) {
        guard let jpeg = image.jpegData(compressionQuality: 0.8) else { return }
        do {
            try draft.addPhoto(jpegData: jpeg)
        } catch {
            alertMessage = "Failed to save photo"
        }
    }

    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            guard draft.canAddPhoto else { break }
            if let raw = try? await item.loadTransferable(type: Data.self) {
                let jpeg = UIImage(data: raw)?.jpegData(compressionQuality: 0.8) ?? raw
                do {
                    try draft.addPhoto(jpegData: jpeg)
                } catch {
                    alertMessage = "Failed to load image"
                }
            }
        }
        pickerItems = []
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.bold())
            .foregroundStyle(ModernColorfulTheme.textPrimary)
    }
}

// MARK: - Helpers

extension View {
    func fieldStyle() -> some View {
        self
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct StepProgress: View {
    let step: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Step \(step) of \(total)")
                .font(.caption2.bold())
                .foregroundStyle(ModernColorfulTheme.textSecondary)
            ProgressView(value: Double(step), total: Double(total))
                .tint(ModernColorfulTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

private struct PhotoThumbnail: View {
    let url: URL
    let onDelete: () -> Void

    var body: some View {
        Group {
            if let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .topTrailing) {
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(.black.opacity(0.6), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(4)
        }
    }
}

private struct IssueCard: View {
    let issue: Issue
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(issue.emoji)
                    .font(.system(size: 28))
                Text(issue.name)
                    .font(.caption.bold())
                    .foregroundStyle(ModernColorfulTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                isSelected ? Color(hex: 0xFFE5E5) : ModernColorfulTheme.lightGray,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ModernColorfulTheme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(ModernColorfulTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(ModernColorfulTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(ModernColorfulTheme.lightGray, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        NewInspectionView()
    }
}

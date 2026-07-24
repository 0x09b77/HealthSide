//
//  AddView.swift
//  Healthside
//
//  Системные пикеры живут во вью, результат уходит в редьюсер как .filePicked.
//

import ComposableArchitecture
import PhotosUI
import SwiftUI

struct AddView: View {
    @Bindable var store: StoreOf<AddFeature>
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Group {
                switch store.step {
                case .source: sourceStep
                case .review: reviewStep
                case .uploaded: uploadedStep
                }
            }
            .background(HSColor.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .sheet(isPresented: $store.isScannerPresented) {
            DocumentScannerView(
                onFinish: { pages in
                    store.isScannerPresented = false
                    handleScan(pages)
                },
                onCancel: { store.isScannerPresented = false }
            )
            .ignoresSafeArea()
        }
        .photosPicker(
            isPresented: $store.isPhotoPickerPresented,
            selection: $photoItem,
            matching: .images
        )
        .fileImporter(
            isPresented: $store.isFileImporterPresented,
            allowedContentTypes: [.pdf, .jpeg, .png, .heic]
        ) { result in
            handleFileImport(result)
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { await handlePhotoItem(item) }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if store.step == .review {
                Button("Back") { store.send(.backTapped) }
                    .foregroundStyle(HSColor.coral)
            } else if store.step == .source {
                Button("Cancel") { store.send(.closeTapped) }
                    .foregroundStyle(HSColor.inkSecondary)
            }
        }
    }

    // MARK: - Step 1: источник

    private var sourceStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Add analysis")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
                .foregroundStyle(HSColor.ink)
            Text("Snap a photo, scan, or pick a file.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)
                .padding(.top, 6)

            VStack(spacing: 12) {
                sourceRow(
                    icon: "camera.viewfinder",
                    title: "Camera",
                    subtitle: "Scan a document"
                ) { store.send(.cameraTapped) }

                sourceRow(
                    icon: "photo.on.rectangle",
                    title: "Photo library",
                    subtitle: "Pick from photos"
                ) { store.send(.photoLibraryTapped) }

                sourceRow(
                    icon: "folder",
                    title: "Files",
                    subtitle: "PDF from Files"
                ) { store.send(.filesTapped) }
            }
            .padding(.top, 26)

            if let error = store.errorMessage {
                errorText(error).padding(.top, 16)
            }

            Spacer()
        }
        .padding(24)
    }

    private func sourceRow(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(HSColor.coralSoft)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(HSColor.coral)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(HSColor.ink)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(HSColor.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(HSColor.labelDisabled)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).fill(HSColor.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(HSColor.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: review

    @ViewBuilder
    private var reviewStep: some View {
        if let file = store.file {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Review & upload")
                        .font(.system(size: 26, weight: .heavy))
                        .tracking(-0.5)
                        .foregroundStyle(HSColor.ink)

                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(HSColor.fieldFill)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: file.mimeType == "application/pdf" ? "doc.text" : "photo")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(HSColor.inkSecondary)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(file.fileName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(HSColor.ink)
                                .lineLimit(1)
                            Text(file.displaySize)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(HSColor.inkSecondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(HSColor.surface))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(HSColor.hairline, lineWidth: 1))
                    .padding(.top, 22)

                    HSTextField(
                        "Label (optional)",
                        placeholder: "Lipid panel — Jun 25",
                        text: $store.label
                    )
                    .padding(.top, 22)

                    if let error = store.errorMessage {
                        errorText(error).padding(.top, 16)
                    }

                    HSButton("Upload", isLoading: store.isUploading) {
                        store.send(.uploadTapped)
                    }
                    .padding(.top, 26)
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Step 3: загружено

    private var uploadedStep: some View {
        VStack(spacing: 16) {
            Spacer()
            RoundedRectangle(cornerRadius: 26)
                .fill(HSColor.successFill)
                .frame(width: 96, height: 96)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(HSColor.success)
                )
            Text("Added")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(HSColor.ink)
            Text("We're reading it now. You can leave — we'll ping you the moment it's ready.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            HSButton("Done") { store.send(.doneTapped) }
        }
        .padding(24)
    }

    // MARK: - Пикеры

    private func handleScan(_ pages: [UIImage]) {
        guard let data = PDFBuilder.pdf(from: pages),
              let file = PickedFile(data: data, suggestedName: nil) else {
            store.send(.pickFailed("Couldn't build a document from that scan."))
            return
        }
        store.send(.filePicked(file))
    }

    private func handlePhotoItem(_ item: PhotosPickerItem) async {
        photoItem = nil
        guard let data = try? await item.loadTransferable(type: Data.self),
              let file = PickedFile(data: data, suggestedName: nil) else {
            store.send(.pickFailed("Unsupported file type. Use a PDF, JPEG, PNG or HEIC."))
            return
        }
        store.send(.filePicked(file))
    }

    private func handleFileImport(_ result: Result<URL, any Error>) {
        guard case let .success(url) = result else { return }
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }

        guard let data = try? Data(contentsOf: url),
              let file = PickedFile(data: data, suggestedName: url.lastPathComponent) else {
            store.send(.pickFailed("Unsupported file type. Use a PDF, JPEG, PNG or HEIC."))
            return
        }
        store.send(.filePicked(file))
    }

    private func errorText(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(HSColor.danger)
    }
}

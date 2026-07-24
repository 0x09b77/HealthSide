//
//  AddFeature.swift
//  Healthside
//
//  Добавление анализа: выбор источника → review (метка) → multipart-загрузка.
//  API отвечает 202 { documentId, status: pending } — файл встаёт в очередь разбора.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AddFeature {

    @ObservableState
    struct State: Equatable {
        nonisolated enum Step: Equatable {
            case source
            case review
            case uploaded
        }

        var step: Step = .source
        var file: PickedFile?
        var label = ""
        var isUploading = false
        var errorMessage: String?

        // Системные пикеры.
        var isScannerPresented = false
        var isFileImporterPresented = false
        var isPhotoPickerPresented = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case cameraTapped
        case photoLibraryTapped
        case filesTapped
        case filePicked(PickedFile)
        case pickFailed(String)
        case backTapped
        case uploadTapped
        case uploadResponse(Result<UploadAcceptedDTO, APIError>)
        case doneTapped
        case closeTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case uploaded
            case dismissed
        }
    }

    @Dependency(\.labResultsService) var labResultsService

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .cameraTapped:
                state.isScannerPresented = true
                return .none

            case .photoLibraryTapped:
                state.isPhotoPickerPresented = true
                return .none

            case .filesTapped:
                state.isFileImporterPresented = true
                return .none

            case let .filePicked(file):
                state.file = file
                state.errorMessage = nil
                state.step = .review
                return .none

            case let .pickFailed(message):
                state.errorMessage = message
                return .none

            case .backTapped:
                state.step = .source
                state.file = nil
                state.errorMessage = nil
                return .none

            case .uploadTapped:
                guard let file = state.file else { return .none }
                state.isUploading = true
                state.errorMessage = nil

                let label = state.label.trimmingCharacters(in: .whitespaces)
                let labResultsService = labResultsService
                return .run { send in
                    do {
                        let accepted = try await labResultsService.upload(
                            fileData: file.data,
                            fileName: file.fileName,
                            mimeType: file.mimeType,
                            label: label.isEmpty ? nil : label
                        )
                        await send(.uploadResponse(.success(accepted)))
                    } catch {
                        await send(.uploadResponse(.failure(error as? APIError ?? .unknown)))
                    }
                }

            case .uploadResponse(.success):
                state.isUploading = false
                state.step = .uploaded
                return .none

            case let .uploadResponse(.failure(error)):
                state.isUploading = false
                state.errorMessage = error.errorDescription
                return .none

            case .doneTapped:
                return .send(.delegate(.uploaded))

            case .closeTapped:
                return .send(.delegate(.dismissed))

            case .delegate:
                return .none
            }
        }
    }
}

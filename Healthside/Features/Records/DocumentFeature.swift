//
//  DocumentFeature.swift
//  Healthside
//
//  Деталь документа: конверт разбора + удаление. Файл живёт в /lab-results,
//  document.id == lab-result id (см. API).
//

import ComposableArchitecture
import Foundation

@Reducer
struct DocumentFeature {

    @ObservableState
    struct State: Equatable {
        var document: DocumentDTO
        var isDeleting = false
        @Presents var alert: AlertState<Action.Alert>?

        var biomarkers: [BiomarkerRow] {
            BiomarkerRow.rows(from: document.payloadJson)
        }

        init(document: DocumentDTO) {
            self.document = document
        }
    }

    enum Action {
        case task
        case documentResponse(Result<DocumentDTO, APIError>)
        case deleteButtonTapped
        case deleteResponse(Result<Bool, APIError>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        enum Alert: Equatable {
            case confirmDelete
        }

        @CasePathable
        enum Delegate {
            case deleted(id: String)
        }
    }

    @Dependency(\.documentsService) var documentsService
    @Dependency(\.labResultsService) var labResultsService
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                // Освежаем и, пока разбор идёт, опрашиваем с бэкоффом.
                // Цикл рвётся при закрытии экрана (эффект привязан к .task вью).
                let id = state.document.id
                let documentsService = documentsService
                let clock = clock
                return .run { send in
                    var attempt = 0
                    while !Task.isCancelled, attempt <= Polling.maxAttempts {
                        if attempt > 0 {
                            try await clock.sleep(for: Polling.delay(attempt: attempt))
                        }
                        do {
                            let document = try await documentsService.document(id: id)
                            await send(.documentResponse(.success(document)))
                            if document.status.isTerminal { return }
                        } catch {
                            await send(.documentResponse(.failure(error as? APIError ?? .unknown)))
                            return
                        }
                        attempt += 1
                    }
                }

            case let .documentResponse(.success(document)):
                state.document = document
                return .none

            case .documentResponse(.failure):
                return .none

            case .deleteButtonTapped:
                state.alert = AlertState {
                    TextState("Delete this record?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDelete) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("This permanently removes your analysis and its data. This can't be undone.")
                }
                return .none

            case .alert(.presented(.confirmDelete)):
                state.isDeleting = true
                let id = state.document.id
                let labResultsService = labResultsService
                return .run { send in
                    do {
                        try await labResultsService.delete(id: id)
                        await send(.deleteResponse(.success(true)))
                    } catch {
                        await send(.deleteResponse(.failure(error as? APIError ?? .unknown)))
                    }
                }

            case .deleteResponse(.success):
                state.isDeleting = false
                return .send(.delegate(.deleted(id: state.document.id)))

            case .deleteResponse(.failure):
                state.isDeleting = false
                return .none

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

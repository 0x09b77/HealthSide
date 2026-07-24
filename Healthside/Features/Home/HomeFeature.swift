//
//  HomeFeature.swift
//  Healthside
//
//  Дашборд: последняя сводка + недавние записи из ленты /documents.
//  Checkup-кольцо/сводка — ждут checkup-эндпоинта на бэкенде (в API его пока нет).
//

import ComposableArchitecture

@Reducer
struct HomeFeature {

    @ObservableState
    struct State: Equatable {
        var documents: [DocumentDTO] = []
        var isLoading = false
        var loadError: String?
        var hasLoaded = false

        /// Последний распарсенный документ со сводкой — под верхнюю карточку.
        var latestSummary: DocumentDTO? {
            documents.first { $0.status == .done && !($0.summary ?? "").isEmpty }
        }

        var recentDocuments: [DocumentDTO] {
            Array(documents.prefix(4))
        }

        var isEmpty: Bool {
            hasLoaded && documents.isEmpty && loadError == nil
        }
    }

    enum Action {
        case task
        case refresh
        case documentsResponse(Result<[DocumentDTO], APIError>)
        case addAnalysisTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case addAnalysisRequested
        }
    }

    @Dependency(\.documentsService) var documentsService
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                return poll(&state)

            case .refresh:
                return load(&state)

            case let .documentsResponse(.success(documents)):
                state.isLoading = false
                state.hasLoaded = true
                state.loadError = nil
                state.documents = documents
                return .none

            case let .documentsResponse(.failure(error)):
                state.isLoading = false
                state.hasLoaded = true
                state.loadError = error.errorDescription
                return .none

            case .addAnalysisTapped:
                return .send(.delegate(.addAnalysisRequested))

            case .delegate:
                return .none
            }
        }
    }

    /// Разовая загрузка (pull-to-refresh).
    private func load(_ state: inout State) -> Effect<Action> {
        state.isLoading = state.documents.isEmpty
        state.loadError = nil
        let documentsService = documentsService
        return .run { send in
            do {
                let documents = try await documentsService.list()
                await send(.documentsResponse(.success(documents)))
            } catch {
                await send(.documentsResponse(.failure(error as? APIError ?? .unknown)))
            }
        }
    }

    /// Загрузка + опрос, пока есть документы в разборе.
    private func poll(_ state: inout State) -> Effect<Action> {
        state.isLoading = state.documents.isEmpty
        state.loadError = nil
        let documentsService = documentsService
        let clock = clock
        return .run { send in
            var attempt = 0
            while !Task.isCancelled, attempt <= Polling.maxAttempts {
                if attempt > 0 {
                    try await clock.sleep(for: Polling.delay(attempt: attempt))
                }
                do {
                    let documents = try await documentsService.list()
                    await send(.documentsResponse(.success(documents)))
                    guard documents.contains(where: { !$0.status.isTerminal }) else { return }
                } catch {
                    await send(.documentsResponse(.failure(error as? APIError ?? .unknown)))
                    return
                }
                attempt += 1
            }
        }
    }
}

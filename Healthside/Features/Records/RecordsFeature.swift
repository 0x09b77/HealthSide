//
//  RecordsFeature.swift
//  Healthside
//
//  Таймлайн документов: поиск, фильтр по типу, drill-down в деталь.
//  Навигация — StackState (см. доку Mobile/Navigation.md).
//

import ComposableArchitecture
import Foundation

@Reducer
struct RecordsFeature {

    @Reducer
    enum Path {
        case document(DocumentFeature)
    }

    @ObservableState
    struct State: Equatable {
        nonisolated enum Filter: String, CaseIterable, Equatable {
            case all
            case labs
            case imaging

            var displayName: String {
                switch self {
                case .all: L10n.Records.Filter.all
                case .labs: L10n.Records.Filter.labs
                case .imaging: L10n.Records.Filter.imaging
                }
            }
        }

        var documents: [DocumentDTO] = []
        var isLoading = false
        var loadError: String?
        var hasLoaded = false
        var searchText = ""
        var filter: Filter = .all
        var path = StackState<Path.State>()

        var filteredDocuments: [DocumentDTO] {
            documents.filter { document in
                let matchesFilter: Bool = switch filter {
                case .all: true
                case .labs: document.documentType == .labPanel
                case .imaging: document.documentType == .imagingReport
                }

                let query = searchText.trimmingCharacters(in: .whitespaces)
                let matchesSearch = query.isEmpty
                    || document.displayTitle.localizedCaseInsensitiveContains(query)
                    || (document.provider ?? "").localizedCaseInsensitiveContains(query)

                return matchesFilter && matchesSearch
            }
        }

        var isEmpty: Bool {
            hasLoaded && documents.isEmpty && loadError == nil
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case task
        case refresh
        case documentsResponse(Result<[DocumentDTO], APIError>)
        case documentTapped(DocumentDTO)
        case path(StackActionOf<Path>)
    }

    @Dependency(\.documentsService) var documentsService
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

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

            case let .documentTapped(document):
                state.path.append(.document(DocumentFeature.State(document: document)))
                return .none

            // Удалили в детали — убираем из списка и возвращаемся назад.
            case let .path(.element(_, action: .document(.delegate(.deleted(id))))):
                state.documents.removeAll { $0.id == id }
                _ = state.path.popLast()
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
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
            try await Polling.run(
                clock: clock,
                fetch: { try await documentsService.list() },
                isTerminal: { documents in !documents.contains { !$0.status.isTerminal } },
                onResult: { await send(.documentsResponse($0)) }
            )
        }
    }
}

extension RecordsFeature.Path.State: Equatable {}

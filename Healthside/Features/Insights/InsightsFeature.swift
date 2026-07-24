//
//  InsightsFeature.swift
//  Healthside
//
//  Тренды биомаркеров. Серии считаются на клиенте из ленты документов
//  (эндпоинта трендов в API нет — см. BiomarkerSeries).
//

import ComposableArchitecture
import Foundation

@Reducer
struct InsightsFeature {

    @Reducer
    enum Path {
        case biomarker(BiomarkerFeature)
    }

    @ObservableState
    struct State: Equatable {
        var documents: [DocumentDTO] = []
        var isLoading = false
        var loadError: String?
        var hasLoaded = false
        var path = StackState<Path.State>()

        var series: [BiomarkerSeries] {
            BiomarkerSeries.series(from: documents)
        }

        var worthWatching: [BiomarkerSeries] {
            series.filter(\.needsAttention)
        }

        var isEmpty: Bool {
            hasLoaded && series.isEmpty && loadError == nil
        }
    }

    enum Action {
        case task
        case refresh
        case documentsResponse(Result<[DocumentDTO], APIError>)
        case seriesTapped(BiomarkerSeries)
        case path(StackActionOf<Path>)
    }

    @Dependency(\.documentsService) var documentsService

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                guard !state.hasLoaded else { return .none }
                return load(&state)

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

            case let .seriesTapped(series):
                state.path.append(.biomarker(BiomarkerFeature.State(series: series)))
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    private func load(_ state: inout State) -> Effect<Action> {
        state.isLoading = true
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
}

extension InsightsFeature.Path.State: Equatable {}

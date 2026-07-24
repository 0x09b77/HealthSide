//
//  MainFeature.swift
//  Healthside
//
//  Таб-бар. По стору на вкладку + выбранная вкладка.
//  Каждая вкладка — независимая фича со своим NavigationStack.
//

import ComposableArchitecture

@Reducer
struct MainFeature {

    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
        var records = RecordsFeature.State()
        var insights = InsightsFeature.State()
        var profile = ProfileFeature.State()
        @Presents var add: AddFeature.State?
    }

    enum Tab: Equatable {
        case home, records, insights, profile
    }

    enum Action {
        case tabSelected(Tab)
        case addTapped
        case add(PresentationAction<AddFeature.Action>)
        case home(HomeFeature.Action)
        case records(RecordsFeature.Action)
        case insights(InsightsFeature.Action)
        case profile(ProfileFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) { HomeFeature() }
        Scope(state: \.records, action: \.records) { RecordsFeature() }
        Scope(state: \.insights, action: \.insights) { InsightsFeature() }
        Scope(state: \.profile, action: \.profile) { ProfileFeature() }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .addTapped, .home(.delegate(.addAnalysisRequested)):
                state.add = AddFeature.State()
                return .none

            // Загрузили — закрываем модалку и освежаем ленты.
            case .add(.presented(.delegate(.uploaded))):
                state.add = nil
                return .merge(
                    .send(.home(.refresh)),
                    .send(.records(.refresh))
                )

            case .add(.presented(.delegate(.dismissed))):
                state.add = nil
                return .none

            case .add, .home, .records, .insights, .profile:
                return .none
            }
        }
        .ifLet(\.$add, action: \.add) { AddFeature() }
    }
}

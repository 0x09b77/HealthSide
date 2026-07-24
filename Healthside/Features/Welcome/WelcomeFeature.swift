//
//  WelcomeFeature.swift
//  Healthside
//
//  Pre-auth онбординг: value-carousel. Delegate уводит в auth (register/login).
//

import ComposableArchitecture

@Reducer
struct WelcomeFeature {

    @ObservableState
    struct State: Equatable {
        var selectedPage = 0
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case getStartedTapped
        case logInTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case getStarted
            case logIn
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { _, action in
            switch action {
            case .binding:
                return .none
            case .getStartedTapped:
                return .send(.delegate(.getStarted))
            case .logInTapped:
                return .send(.delegate(.logIn))
            case .delegate:
                return .none
            }
        }
    }
}

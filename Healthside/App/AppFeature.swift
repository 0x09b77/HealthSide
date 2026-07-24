//
//  AppFeature.swift
//  Healthside
//
//  Корневой редьюсер. Верхнеуровневое состояние сессии: launching / welcome / auth / main.
//  Навигация на этом уровне — смена кейса состояния, без push/pop.
//  См. доку: Mobile/Architecture.md, Mobile/Navigation.md.
//

import ComposableArchitecture

@Reducer
struct AppFeature {

    @ObservableState
    enum State: Equatable {
        case launching
        case welcome(WelcomeFeature.State)
        case auth(AuthFeature.State)
        case setup(SetupFeature.State)
        case main(MainFeature.State)

        init() { self = .launching }
    }

    enum Action {
        case onAppear
        case sessionExpired
        case welcome(WelcomeFeature.Action)
        case auth(AuthFeature.Action)
        case setup(SetupFeature.Action)
        case main(MainFeature.Action)
        // TODO: deep links из пушей
    }

    @Dependency(\.tokenStore) var tokenStore
    @Dependency(\.sessionEvents) var sessionEvents
    @Dependency(\.onboarding) var onboarding

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard case .launching = state else { return .none }
                // Начальный роут: сессия → main/setup (по согласию); иначе welcome или auth.
                if tokenStore.isAuthenticated {
                    state = authenticatedDestination()
                } else if onboarding.hasCompletedWelcome() {
                    state = .auth(AuthFeature.State())
                } else {
                    state = .welcome(WelcomeFeature.State())
                }
                // Подписка на протухание сессии (single-flight refresh не спас).
                let sessionEvents = sessionEvents
                return .run { send in
                    for await event in sessionEvents.stream() {
                        switch event {
                        case .expired:
                            await send(.sessionExpired)
                        }
                    }
                }

            case .sessionExpired:
                state = .auth(AuthFeature.State())
                return .none

            case .welcome(.delegate(.getStarted)):
                onboarding.setWelcomeCompleted(true)
                state = .auth(AuthFeature.State(mode: .register))
                return .none

            case .welcome(.delegate(.logIn)):
                onboarding.setWelcomeCompleted(true)
                state = .auth(AuthFeature.State(mode: .login))
                return .none

            case .auth(.delegate(.authenticated)):
                state = authenticatedDestination()
                return .none

            case .setup(.delegate(.completed)):
                state = .main(MainFeature.State())
                return .none

            case .main(.profile(.delegate(.loggedOut))):
                state = .auth(AuthFeature.State())
                return .none

            case .welcome, .auth, .setup, .main:
                return .none
            }
        }
        .ifCaseLet(\.welcome, action: \.welcome) { WelcomeFeature() }
        .ifCaseLet(\.auth, action: \.auth) { AuthFeature() }
        .ifCaseLet(\.setup, action: \.setup) { SetupFeature() }
        .ifCaseLet(\.main, action: \.main) { MainFeature() }
    }

    /// Куда идти после успешной авторизации: согласие принято → main, иначе → setup.
    private func authenticatedDestination() -> State {
        onboarding.hasAcceptedConsent()
            ? .main(MainFeature.State())
            : .setup(SetupFeature.State())
    }
}

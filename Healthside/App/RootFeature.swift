//
//  RootFeature.swift
//  Healthside
//
//  Композит верхнего уровня: роутинг сессии (AppFeature) + биометрик-лок,
//  который ортогонален роутингу и живёт крышкой поверх всего.
//

import ComposableArchitecture

@Reducer
struct RootFeature {

    @ObservableState
    struct State: Equatable {
        var app = AppFeature.State()
        var lock = AppLockFeature.State()

        /// Лочим только то, что за авторизацией — экран логина закрывать незачем.
        var isAuthenticatedArea: Bool {
            switch app {
            case .setup, .main: true
            case .launching, .welcome, .auth: false
            }
        }
    }

    enum Action {
        case app(AppFeature.Action)
        case lock(AppLockFeature.Action)
        case phaseChanged(AppPhase)
    }

    @Dependency(\.tokenStore) var tokenStore
    @Dependency(\.onboarding) var onboarding

    var body: some Reducer<State, Action> {
        Scope(state: \.app, action: \.app) { AppFeature() }
        Scope(state: \.lock, action: \.lock) { AppLockFeature() }

        Reduce { state, action in
            switch action {
            case let .phaseChanged(phase):
                guard state.isAuthenticatedArea else {
                    state.lock.isLocked = false
                    return .none
                }
                return .send(.lock(.phaseChanged(phase)))

            // Выход с экрана лока: чистим сессию и уводим на логин.
            case .lock(.delegate(.logOutRequested)):
                try? tokenStore.clear()
                // Согласие — per-account, не per-device (см. ProfileFeature.logoutTapped).
                onboarding.setConsentAccepted(false)
                state.app = .auth(AuthFeature.State())
                return .none

            case .app:
                // Вышли из авторизованной зоны (логаут, протухшая сессия) — снимаем лок.
                if !state.isAuthenticatedArea {
                    state.lock.isLocked = false
                }
                return .none
            case .lock:
                return .none
            }
        }
    }
}

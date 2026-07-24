//
//  AppLockFeature.swift
//  Healthside
//
//  Биометрический лок приложения. Экран-крышка поверх всего контента:
//  - при запуске (если лок включён);
//  - при возврате из фона;
//  - при уходе в неактивное состояние — чтобы контент не попал в снапшот
//    переключателя приложений.
//

import ComposableArchitecture

/// Фаза жизненного цикла сцены (без завязки на SwiftUI внутри редьюсера).
public nonisolated enum AppPhase: Sendable, Equatable {
    case active
    case inactive
    case background
}

@Reducer
struct AppLockFeature {

    @ObservableState
    struct State: Equatable {
        var isLocked = false
        var isAuthenticating = false
        var didFail = false
        var biometryKind: BiometryKind = .none
    }

    enum Action {
        case task
        case phaseChanged(AppPhase)
        case unlockTapped
        case unlockResponse(Bool)
        case logOutTapped
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case logOutRequested
        }
    }

    @Dependency(\.onboarding) var onboarding
    @Dependency(\.biometrics) var biometrics

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.biometryKind = biometrics.availableBiometry()
                guard isLockEnabled else { return .none }
                state.isLocked = true
                return .send(.unlockTapped)

            case .phaseChanged(.background):
                guard isLockEnabled else { return .none }
                state.isLocked = true
                state.didFail = false
                return .none

            case .phaseChanged(.active):
                // Промпт биометрии сам делает сцену неактивной — не перезапускаем его.
                guard state.isLocked, !state.isAuthenticating else { return .none }
                return .send(.unlockTapped)

            case .phaseChanged(.inactive):
                return .none

            case .unlockTapped:
                guard !state.isAuthenticating else { return .none }
                state.isAuthenticating = true
                state.didFail = false
                let biometrics = biometrics
                return .run { send in
                    await send(.unlockResponse(await biometrics.evaluate("Unlock Healthside")))
                }

            case let .unlockResponse(isSuccess):
                state.isAuthenticating = false
                state.isLocked = !isSuccess
                state.didFail = !isSuccess
                return .none

            case .logOutTapped:
                state.isLocked = false
                state.didFail = false
                return .send(.delegate(.logOutRequested))

            case .delegate:
                return .none
            }
        }
    }

    private var isLockEnabled: Bool {
        onboarding.isBiometricLockEnabled() && biometrics.availableBiometry() != .none
    }
}

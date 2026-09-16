//
//  ProfileFeature.swift
//  Healthside
//
//  Профиль: аккаунт, безопасность (биометрик-лок), приватность, выход.
//  Часть строк дизайна не имеет эндпоинтов в API — они показаны выключенными.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ProfileFeature {

    @ObservableState
    struct State: Equatable {
        var user: UserDTO?
        var isLoading = false
        var loadError: String?
        var biometryKind: BiometryKind = .none
        var isBiometricLockEnabled = false
        var isLoggingOut = false

        var hasBiometry: Bool { biometryKind != .none }

        var memberSince: String? {
            user?.createdAt?.formatted(.dateTime.month(.wide).year())
        }

        /// Инициал для аватара (имени в API нет — берём из email).
        var avatarInitial: String {
            String(user?.email.first ?? "?").uppercased()
        }
    }

    enum Action {
        case task
        case userResponse(Result<UserDTO, APIError>)
        case biometricLockToggled(Bool)
        case biometricEvaluated(Bool)
        case logoutTapped
        case logoutFinished
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case loggedOut
        }
    }

    @Dependency(\.userService) var userService
    @Dependency(\.authService) var authService
    @Dependency(\.tokenStore) var tokenStore
    @Dependency(\.onboarding) var onboarding
    @Dependency(\.biometrics) var biometrics

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.biometryKind = biometrics.availableBiometry()
                state.isBiometricLockEnabled = onboarding.isBiometricLockEnabled()

                guard state.user == nil else { return .none }
                state.isLoading = true
                let userService = userService
                return .run { send in
                    do {
                        let user = try await userService.me()
                        await send(.userResponse(.success(user)))
                    } catch {
                        await send(.userResponse(.failure(error as? APIError ?? .unknown)))
                    }
                }

            case let .userResponse(.success(user)):
                state.isLoading = false
                state.loadError = nil
                state.user = user
                return .none

            case let .userResponse(.failure(error)):
                state.isLoading = false
                state.loadError = error.errorDescription
                return .none

            case let .biometricLockToggled(isOn):
                // Выключаем сразу; включаем только после успешной проверки.
                guard isOn else {
                    state.isBiometricLockEnabled = false
                    onboarding.setBiometricLockEnabled(false)
                    return .none
                }
                let biometrics = biometrics
                let reason = "Enable \(state.biometryKind.displayName) to lock Healthside."
                return .run { send in
                    await send(.biometricEvaluated(await biometrics.evaluate(reason)))
                }

            case let .biometricEvaluated(isSuccess):
                state.isBiometricLockEnabled = isSuccess
                onboarding.setBiometricLockEnabled(isSuccess)
                return .none

            case .logoutTapped:
                state.isLoggingOut = true
                let authService = authService
                let tokenStore = tokenStore
                let refreshToken = tokenStore.refreshToken
                // Согласие на обработку — per-account, а не per-device: следующий,
                // кто залогинится на этом устройстве, должен снова пройти Consent.
                onboarding.setConsentAccepted(false)
                return .run { send in
                    // Отзыв на сервере идемпотентен; локально чистим в любом случае.
                    if let refreshToken {
                        try? await authService.logout(refreshToken: refreshToken)
                    }
                    try? tokenStore.clear()
                    await send(.logoutFinished)
                }

            case .logoutFinished:
                state.isLoggingOut = false
                return .send(.delegate(.loggedOut))

            case .delegate:
                return .none
            }
        }
    }
}

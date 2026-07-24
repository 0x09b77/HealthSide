//
//  AuthFeature.swift
//  Healthside
//
//  Экран авторизации: login / register в одном месте.
//  Успех → сохраняем токены в Keychain и делегируем наверх (AppFeature → main).
//

import ComposableArchitecture
import Foundation

@Reducer
struct AuthFeature {

    @ObservableState
    struct State: Equatable {
        nonisolated enum Mode: Equatable {
            case login
            case register
        }

        var mode: Mode = .login
        var email = ""
        var password = ""
        var isSubmitting = false
        var emailError: String?
        var passwordError: String?

        var canSubmit: Bool {
            !email.isEmpty && !password.isEmpty && !isSubmitting
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case modeToggled
        case submitTapped
        case forgotPasswordTapped
        case submitFailed(APIError)
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case authenticated
        }
    }

    @Dependency(\.authService) var authService
    @Dependency(\.tokenStore) var tokenStore

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .modeToggled:
                state.mode = state.mode == .login ? .register : .login
                state.emailError = nil
                state.passwordError = nil
                return .none

            case .submitTapped:
                guard validate(&state) else { return .none }
                state.isSubmitting = true

                let email = state.email
                let password = state.password
                let mode = state.mode
                let authService = authService
                let tokenStore = tokenStore

                return .run { send in
                    do {
                        if mode == .register {
                            _ = try await authService.register(email: email, password: password)
                        }
                        let tokens = try await authService.login(email: email, password: password)
                        try tokenStore.save(TokenPair(tokens))
                        await send(.delegate(.authenticated))
                    } catch {
                        await send(.submitFailed(error as? APIError ?? .unknown))
                    }
                }

            case let .submitFailed(error):
                state.isSubmitting = false
                if state.mode == .login, error == .unauthorized {
                    state.passwordError = "Wrong email or password"
                } else if state.mode == .register, case .conflict = error {
                    state.emailError = "Email already registered"
                } else {
                    state.passwordError = error.errorDescription
                }
                return .none

            case .forgotPasswordTapped:
                // TODO: восстановление пароля (эндпоинта пока нет в API).
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func validate(_ state: inout State) -> Bool {
        state.emailError = nil
        state.passwordError = nil
        var isValid = true

        if !state.email.contains("@") || state.email.count < 3 {
            state.emailError = "Enter a valid email"
            isValid = false
        }

        if state.mode == .register, state.password.count < 8 {
            state.passwordError = "Password must be at least 8 characters"
            isValid = false
        } else if state.password.isEmpty {
            state.passwordError = "Enter your password"
            isValid = false
        }

        return isValid
    }
}

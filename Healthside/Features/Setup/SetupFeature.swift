//
//  SetupFeature.swift
//  Healthside
//
//  Пост-signup сетап: Consent → Notifications → Face ID → main.
//  Consent — обязательный privacy-гейт; пермишены опциональны (skip).
//

import ComposableArchitecture

@Reducer
struct SetupFeature {

    @ObservableState
    struct State: Equatable {
        nonisolated enum Step: Equatable {
            case consent
            case notifications
            case faceID
        }

        var step: Step = .consent
        var consentAccepted = false
        var isRequestingPermission = false
        var biometry: BiometryKind = .none
    }

    enum Action {
        case onAppear
        case consentToggled
        case agreeConsentTapped
        case enableNotificationsTapped
        case skipNotificationsTapped
        case notificationsResponse(Bool)
        case enableFaceIDTapped
        case skipFaceIDTapped
        case faceIDResponse(Bool)
        case delegate(Delegate)

        @CasePathable
        enum Delegate {
            case completed
        }
    }

    @Dependency(\.onboarding) var onboarding
    @Dependency(\.notifications) var notifications
    @Dependency(\.biometrics) var biometrics

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.biometry = biometrics.availableBiometry()
                return .none

            case .consentToggled:
                state.consentAccepted.toggle()
                return .none

            case .agreeConsentTapped:
                guard state.consentAccepted else { return .none }
                onboarding.setConsentAccepted(true)
                state.step = .notifications
                return .none

            case .enableNotificationsTapped:
                state.isRequestingPermission = true
                let notifications = notifications
                return .run { send in
                    let granted = await notifications.requestAuthorization()
                    await send(.notificationsResponse(granted))
                }

            case .notificationsResponse:
                state.isRequestingPermission = false
                return advanceAfterNotifications(&state)

            case .skipNotificationsTapped:
                return advanceAfterNotifications(&state)

            case .enableFaceIDTapped:
                state.isRequestingPermission = true
                let biometrics = biometrics
                let reason = "Enable \(state.biometry.displayName) to lock Healthside."
                return .run { send in
                    let ok = await biometrics.evaluate(reason)
                    await send(.faceIDResponse(ok))
                }

            case let .faceIDResponse(granted):
                state.isRequestingPermission = false
                if granted { onboarding.setBiometricLockEnabled(true) }
                return .send(.delegate(.completed))

            case .skipFaceIDTapped:
                return .send(.delegate(.completed))

            case .delegate:
                return .none
            }
        }
    }

    private func advanceAfterNotifications(_ state: inout State) -> Effect<Action> {
        if state.biometry == .none {
            return .send(.delegate(.completed))
        }
        state.step = .faceID
        return .none
    }
}

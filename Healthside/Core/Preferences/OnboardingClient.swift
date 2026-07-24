//
//  OnboardingClient.swift
//  Healthside
//
//  Персистентные флаги онбординга/сетапа (UserDefaults):
//  - welcome пройден (первый запуск);
//  - согласие на обработку принято (privacy-гейт);
//  - включён биометрик-лок.
//

import ComposableArchitecture
import Foundation

public nonisolated struct OnboardingClient: Sendable {
    public var hasCompletedWelcome: @Sendable () -> Bool
    public var setWelcomeCompleted: @Sendable (Bool) -> Void
    public var hasAcceptedConsent: @Sendable () -> Bool
    public var setConsentAccepted: @Sendable (Bool) -> Void
    public var isBiometricLockEnabled: @Sendable () -> Bool
    public var setBiometricLockEnabled: @Sendable (Bool) -> Void

    public init(
        hasCompletedWelcome: @escaping @Sendable () -> Bool,
        setWelcomeCompleted: @escaping @Sendable (Bool) -> Void,
        hasAcceptedConsent: @escaping @Sendable () -> Bool,
        setConsentAccepted: @escaping @Sendable (Bool) -> Void,
        isBiometricLockEnabled: @escaping @Sendable () -> Bool,
        setBiometricLockEnabled: @escaping @Sendable (Bool) -> Void
    ) {
        self.hasCompletedWelcome = hasCompletedWelcome
        self.setWelcomeCompleted = setWelcomeCompleted
        self.hasAcceptedConsent = hasAcceptedConsent
        self.setConsentAccepted = setConsentAccepted
        self.isBiometricLockEnabled = isBiometricLockEnabled
        self.setBiometricLockEnabled = setBiometricLockEnabled
    }
}

private nonisolated enum OnboardingClientKey: DependencyKey {
    static let liveValue = OnboardingClient(
        hasCompletedWelcome: { UserDefaults.standard.bool(forKey: "welcome.completed") },
        setWelcomeCompleted: { UserDefaults.standard.set($0, forKey: "welcome.completed") },
        hasAcceptedConsent: { UserDefaults.standard.bool(forKey: "consent.accepted") },
        setConsentAccepted: { UserDefaults.standard.set($0, forKey: "consent.accepted") },
        isBiometricLockEnabled: { UserDefaults.standard.bool(forKey: "biometricLock.enabled") },
        setBiometricLockEnabled: { UserDefaults.standard.set($0, forKey: "biometricLock.enabled") }
    )

    static let testValue = OnboardingClient(
        hasCompletedWelcome: { false },
        setWelcomeCompleted: { _ in },
        hasAcceptedConsent: { false },
        setConsentAccepted: { _ in },
        isBiometricLockEnabled: { false },
        setBiometricLockEnabled: { _ in }
    )
}

public extension DependencyValues {
    nonisolated var onboarding: OnboardingClient {
        get { self[OnboardingClientKey.self] }
        set { self[OnboardingClientKey.self] = newValue }
    }
}

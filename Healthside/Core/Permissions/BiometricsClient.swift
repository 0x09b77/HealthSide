//
//  BiometricsClient.swift
//  Healthside
//
//  Биометрия (Face ID / Touch ID) через LocalAuthentication.
//

import ComposableArchitecture
import LocalAuthentication

public nonisolated enum BiometryKind: Sendable, Equatable {
    case none
    case touchID
    case faceID
    case opticID

    public var displayName: String {
        switch self {
        case .none: "biometrics"
        case .touchID: "Touch ID"
        case .faceID: "Face ID"
        case .opticID: "Optic ID"
        }
    }
}

public nonisolated struct BiometricsClient: Sendable {
    /// Тип доступной биометрии (или .none).
    public var availableBiometry: @Sendable () -> BiometryKind
    /// Запрашивает биометрию. Возвращает успех.
    public var evaluate: @Sendable (_ reason: String) async -> Bool

    public init(
        availableBiometry: @escaping @Sendable () -> BiometryKind,
        evaluate: @escaping @Sendable (_ reason: String) async -> Bool
    ) {
        self.availableBiometry = availableBiometry
        self.evaluate = evaluate
    }
}

private nonisolated enum BiometricsClientKey: DependencyKey {
    static let liveValue = BiometricsClient(
        availableBiometry: {
            let context = LAContext()
            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                return .none
            }
            switch context.biometryType {
            case .faceID: return .faceID
            case .touchID: return .touchID
            case .opticID: return .opticID
            default: return .none
            }
        },
        evaluate: { reason in
            let context = LAContext()
            do {
                return try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason
                )
            } catch {
                return false
            }
        }
    )

    static let testValue = BiometricsClient(
        availableBiometry: { .none },
        evaluate: { _ in false }
    )
}

public extension DependencyValues {
    nonisolated var biometrics: BiometricsClient {
        get { self[BiometricsClientKey.self] }
        set { self[BiometricsClientKey.self] = newValue }
    }
}

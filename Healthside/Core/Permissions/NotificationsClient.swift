//
//  NotificationsClient.swift
//  Healthside
//
//  Запрос разрешения на пуши. Регистрация в APNs/FCM — отдельно (PushClient).
//

import ComposableArchitecture
import UserNotifications

public nonisolated struct NotificationsClient: Sendable {
    /// Запрашивает разрешение. Возвращает, дал ли пользователь согласие.
    public var requestAuthorization: @Sendable () async -> Bool

    public init(requestAuthorization: @escaping @Sendable () async -> Bool) {
        self.requestAuthorization = requestAuthorization
    }
}

private nonisolated enum NotificationsClientKey: DependencyKey {
    static let liveValue = NotificationsClient(
        requestAuthorization: {
            let center = UNUserNotificationCenter.current()
            let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted ?? false
        }
    )

    static let testValue = NotificationsClient(requestAuthorization: { false })
}

public extension DependencyValues {
    nonisolated var notifications: NotificationsClient {
        get { self[NotificationsClientKey.self] }
        set { self[NotificationsClientKey.self] = newValue }
    }
}

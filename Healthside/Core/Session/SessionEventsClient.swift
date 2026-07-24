//
//  SessionEventsClient.swift
//  Healthside
//
//  Канал глобальных событий сессии. AuthInterceptor эмитит .expired при
//  протухшем refresh; AppFeature слушает поток и уводит в auth.
//

import ComposableArchitecture
import Foundation

public nonisolated enum SessionEvent: Sendable, Equatable {
    case expired
}

public nonisolated struct SessionEventsClient: Sendable {
    public var stream: @Sendable () -> AsyncStream<SessionEvent>
    public var send: @Sendable (SessionEvent) -> Void

    public init(
        stream: @escaping @Sendable () -> AsyncStream<SessionEvent>,
        send: @escaping @Sendable (SessionEvent) -> Void
    ) {
        self.stream = stream
        self.send = send
    }
}

private nonisolated enum SessionEventsClientKey: DependencyKey {
    static let liveValue: SessionEventsClient = {
        let (stream, continuation) = AsyncStream<SessionEvent>.makeStream()
        return SessionEventsClient(
            stream: { stream },
            send: { continuation.yield($0) }
        )
    }()

    static let testValue = SessionEventsClient(
        stream: { AsyncStream { _ in } },
        send: { _ in }
    )
}

public extension DependencyValues {
    nonisolated var sessionEvents: SessionEventsClient {
        get { self[SessionEventsClientKey.self] }
        set { self[SessionEventsClientKey.self] = newValue }
    }
}

//
//  ITokenStore.swift
//  Healthside
//
//  Хранилище токенов. Реализация — Keychain (live) / in-memory (test/preview).
//

import Foundation

public protocol ITokenStore: Sendable {
    /// Текущая пара токенов, либо nil если не залогинен.
    nonisolated func load() -> TokenPair?

    /// Сохранить/перезаписать пару.
    nonisolated func save(_ tokens: TokenPair) throws

    /// Стереть токены (logout / протухший refresh).
    nonisolated func clear() throws
}

public extension ITokenStore {
    nonisolated var accessToken: String? { load()?.accessToken }
    nonisolated var refreshToken: String? { load()?.refreshToken }
    nonisolated var isAuthenticated: Bool { load() != nil }
}

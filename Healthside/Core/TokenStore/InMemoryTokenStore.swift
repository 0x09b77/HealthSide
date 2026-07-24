//
//  InMemoryTokenStore.swift
//  Healthside
//
//  Реализация для тестов и SwiftUI-превью (без Keychain).
//

import Foundation

public nonisolated final class InMemoryTokenStore: ITokenStore, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: TokenPair?

    public init(tokens: TokenPair? = nil) {
        self.storage = tokens
    }

    public func load() -> TokenPair? {
        lock.withLock { storage }
    }

    public func save(_ tokens: TokenPair) throws {
        lock.withLock { storage = tokens }
    }

    public func clear() throws {
        lock.withLock { storage = nil }
    }
}

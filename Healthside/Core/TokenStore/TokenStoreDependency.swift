//
//  TokenStoreDependency.swift
//  Healthside
//

import ComposableArchitecture

private nonisolated enum TokenStoreKey: DependencyKey {
    static let liveValue: any ITokenStore = KeychainTokenStore()
    static let testValue: any ITokenStore = InMemoryTokenStore()
    static let previewValue: any ITokenStore = InMemoryTokenStore()
}

public extension DependencyValues {
    nonisolated var tokenStore: any ITokenStore {
        get { self[TokenStoreKey.self] }
        set { self[TokenStoreKey.self] = newValue }
    }
}

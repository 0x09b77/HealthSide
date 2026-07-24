//
//  AuthModels.swift
//  Healthside
//

import Foundation

/// Тело register/login.
public nonisolated struct AuthCredentialsDTO: Codable, Equatable, Sendable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// Тело refresh/logout.
public nonisolated struct RefreshTokenRequestDTO: Codable, Equatable, Sendable {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

/// Пара токенов.
public nonisolated struct TokenPairDTO: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

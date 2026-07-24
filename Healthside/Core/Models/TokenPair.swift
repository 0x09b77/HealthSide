//
//  TokenPair.swift
//  Healthside
//
//  Доменная пара токенов (то, что храним в Keychain), отдельно от wire-DTO.
//

import Foundation

public nonisolated struct TokenPair: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    public init(_ dto: TokenPairDTO) {
        self.init(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
    }
}

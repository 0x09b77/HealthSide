//
//  AuthService.swift
//  Healthside
//

import ComposableArchitecture
import Foundation

public nonisolated struct AuthService: IAuthService {
    private let network: any INetwork

    public init(network: any INetwork) {
        self.network = network
    }

    public func register(email: String, password: String) async throws -> UserDTO {
        try await mappingErrors {
            let body = try JSONEncoder().encode(AuthCredentialsDTO(email: email, password: password))
            return try await network.request(AuthEndpoint.register(body))
        }
    }

    public func login(email: String, password: String) async throws -> TokenPairDTO {
        try await mappingErrors {
            let body = try JSONEncoder().encode(AuthCredentialsDTO(email: email, password: password))
            return try await network.request(AuthEndpoint.login(body))
        }
    }

    public func refresh(refreshToken: String) async throws -> TokenPairDTO {
        try await mappingErrors {
            let body = try JSONEncoder().encode(RefreshTokenRequestDTO(refreshToken: refreshToken))
            return try await network.request(AuthEndpoint.refresh(body))
        }
    }

    public func logout(refreshToken: String) async throws {
        try await mappingErrors {
            let body = try JSONEncoder().encode(RefreshTokenRequestDTO(refreshToken: refreshToken))
            try await network.send(AuthEndpoint.logout(body))
        }
    }

    private func mappingErrors<T>(_ work: () async throws -> T) async throws -> T {
        do {
            return try await work()
        } catch {
            throw APIErrorMapper.map(error)
        }
    }
}

// MARK: - Dependency

private enum AuthServiceKey: DependencyKey {
    static var liveValue: any IAuthService {
        @Dependency(\.network) var network
        return AuthService(network: network)
    }
}

public extension DependencyValues {
    nonisolated var authService: any IAuthService {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
}

//
//  UserService.swift
//  Healthside
//

import ComposableArchitecture
import Foundation

public nonisolated struct UserService: IUserService {
    private let network: any INetwork

    public init(network: any INetwork) {
        self.network = network
    }

    public func me() async throws -> UserDTO {
        do {
            return try await network.request(UserEndpoint.me)
        } catch {
            throw APIErrorMapper.map(error)
        }
    }
}

// MARK: - Dependency

private enum UserServiceKey: DependencyKey {
    static var liveValue: any IUserService {
        @Dependency(\.network) var network
        return UserService(network: network)
    }
}

public extension DependencyValues {
    nonisolated var userService: any IUserService {
        get { self[UserServiceKey.self] }
        set { self[UserServiceKey.self] = newValue }
    }
}

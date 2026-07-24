//
//  IUserService.swift
//  Healthside
//

import Foundation

public protocol IUserService: Sendable {
    /// Профиль текущего пользователя.
    nonisolated func me() async throws -> UserDTO
}

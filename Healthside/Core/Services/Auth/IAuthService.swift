//
//  IAuthService.swift
//  Healthside
//

import Foundation

public protocol IAuthService: Sendable {
    /// Регистрация. Возвращает созданного пользователя (201).
    nonisolated func register(email: String, password: String) async throws -> UserDTO

    /// Логин. Возвращает пару токенов (200).
    nonisolated func login(email: String, password: String) async throws -> TokenPairDTO

    /// Обмен refresh-токена на новую пару (refresh ротируется).
    nonisolated func refresh(refreshToken: String) async throws -> TokenPairDTO

    /// Отзыв refresh-токена (идемпотентно, 204).
    nonisolated func logout(refreshToken: String) async throws
}

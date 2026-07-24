//
//  IRequestInterceptor.swift
//  Healthside
//
//  Перехватчик запроса: adapt (модификация перед отправкой) + retry (решение о повторе).
//  Оба метода async — например, adapt может дождаться свежего токена.
//

import Foundation

public nonisolated enum RetryAction: Sendable {
    case retry(delay: TimeInterval)
    case doNotRetry
}

public protocol IRequestInterceptor: Sendable {
    /// Модифицирует запрос перед отправкой (заголовки, авторизация и т.д.).
    nonisolated func adapt(_ request: URLRequest) async throws -> URLRequest

    /// Решает, повторять ли запрос после ошибки. `retryCount` — сколько повторов уже было.
    nonisolated func retry(_ request: URLRequest, dueTo error: any Error, retryCount: Int) async -> RetryAction
}

public extension IRequestInterceptor {
    nonisolated func adapt(_ request: URLRequest) async throws -> URLRequest { request }

    nonisolated func retry(_ request: URLRequest, dueTo error: any Error, retryCount: Int) async -> RetryAction {
        .doNotRetry
    }
}

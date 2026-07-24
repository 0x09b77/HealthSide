//
//  AuthInterceptor.swift
//  Healthside
//
//  Авторизация запросов + refresh на 401.
//  - adapt: кладёт `Authorization: Bearer <access>` из TokenStore
//    (кроме /auth/* — они без токена).
//  - retry: на 401 один раз делает single-flight refresh, сохраняет новую пару
//    и повторяет запрос (adapt подхватит свежий токен). Протух refresh →
//    чистим Keychain и эмитим sessionExpired.
//

import ComposableArchitecture
import Foundation

public nonisolated struct AuthInterceptor: IRequestInterceptor {
    @Dependency(\.tokenStore) private var tokenStore
    @Dependency(\.authService) private var authService
    @Dependency(\.sessionEvents) private var sessionEvents

    private let refreshCoordinator = RefreshCoordinator()

    public init() {}

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        guard !Self.isAuthEndpoint(request) else { return request }
        var request = request
        if let token = tokenStore.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    public func retry(_ request: URLRequest, dueTo error: any Error, retryCount: Int) async -> RetryAction {
        guard !Self.isAuthEndpoint(request),
              retryCount == 0,
              case NetworkError.invalidStatusCode(401, _) = error,
              let refreshToken = tokenStore.refreshToken
        else {
            return .doNotRetry
        }

        let service = authService
        do {
            let pair = try await refreshCoordinator.refresh {
                try await service.refresh(refreshToken: refreshToken)
            }
            try? tokenStore.save(TokenPair(pair))
            return .retry(delay: 0)
        } catch {
            try? tokenStore.clear()
            sessionEvents.send(.expired)
            return .doNotRetry
        }
    }

    private static func isAuthEndpoint(_ request: URLRequest) -> Bool {
        request.url?.path.hasPrefix("/auth") ?? false
    }
}

/// Сериализует refresh: параллельные 401 ждут один общий вызов, а не спамят refresh.
private actor RefreshCoordinator {
    private var inFlight: Task<TokenPairDTO, any Error>?

    func refresh(_ operation: @escaping @Sendable () async throws -> TokenPairDTO) async throws -> TokenPairDTO {
        if let inFlight {
            return try await inFlight.value
        }
        let task = Task { try await operation() }
        inFlight = task
        defer { inFlight = nil }
        return try await task.value
    }
}

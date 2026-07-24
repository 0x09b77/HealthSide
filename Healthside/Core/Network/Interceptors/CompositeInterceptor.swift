//
//  CompositeInterceptor.swift
//  Healthside
//
//  Объединяет несколько интерцепторов в один: adapt применяется по цепочке,
//  retry — первый, кто согласился повторить, побеждает.
//

import Foundation

public nonisolated struct CompositeInterceptor: IRequestInterceptor {
    private let interceptors: [any IRequestInterceptor]

    public init(_ interceptors: [any IRequestInterceptor]) {
        self.interceptors = interceptors
    }

    public nonisolated func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        for interceptor in interceptors {
            request = try await interceptor.adapt(request)
        }
        return request
    }

    public nonisolated func retry(_ request: URLRequest, dueTo error: any Error, retryCount: Int) async -> RetryAction {
        for interceptor in interceptors {
            if case let .retry(delay) = await interceptor.retry(request, dueTo: error, retryCount: retryCount) {
                return .retry(delay: delay)
            }
        }
        return .doNotRetry
    }
}

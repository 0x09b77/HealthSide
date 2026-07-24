//
//  RetryInterceptor.swift
//  Healthside
//
//  Повторяет запрос при транзиентных сетевых ошибках (offline / timeout).
//

import Foundation

public nonisolated struct RetryInterceptor: IRequestInterceptor {
    private let maxRetryCount: Int
    private let delay: TimeInterval

    public init(maxRetryCount: Int = 2, delay: TimeInterval = 1) {
        self.maxRetryCount = maxRetryCount
        self.delay = delay
    }

    public nonisolated func retry(_ request: URLRequest, dueTo error: any Error, retryCount: Int) async -> RetryAction {
        guard retryCount < maxRetryCount, let error = error as? NetworkError else {
            return .doNotRetry
        }
        switch error {
        case .offline, .timedOut:
            return .retry(delay: delay)
        default:
            return .doNotRetry
        }
    }
}

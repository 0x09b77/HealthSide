//
//  INetworkConfig.swift
//  Healthside
//
//  Конфигурация сетевого клиента: базовый URL, общие заголовки/параметры,
//  а также общие интерцептор/валидатор/парсер/логгер (можно переопределить на запрос).
//

import Foundation

public protocol INetworkConfig: Sendable {
    nonisolated var baseURL: @Sendable () -> String { get }
    nonisolated var commonHeaders: RequestHeaders? { get }
    nonisolated var commonParameters: RequestParameters? { get }
    nonisolated var requestTimeout: TimeInterval { get }
    nonisolated var interceptor: (any IRequestInterceptor)? { get }
    nonisolated var validator: (any IRequestValidator)? { get }
    nonisolated var parser: (any IDataParser)? { get }
    nonisolated var logger: (any INetworkLogger)? { get }
}

public extension INetworkConfig {
    nonisolated func mergeHeaders(_ headers: RequestHeaders?) -> RequestHeaders? {
        guard var headers else { return commonHeaders }
        guard let commonHeaders else { return headers }
        headers.merge(commonHeaders) { current, _ in current }
        return headers
    }

    nonisolated func mergeParameters(_ parameters: RequestParameters?) -> RequestParameters? {
        guard var parameters else { return commonParameters }
        guard let commonParameters else { return parameters }
        parameters.merge(commonParameters) { current, _ in current }
        return parameters
    }
}

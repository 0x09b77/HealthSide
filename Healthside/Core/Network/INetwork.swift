//
//  INetwork.swift
//  Healthside
//
//  Публичный контракт сетевого слоя. Всё на async/await.
//  Отмена — через отмену Task, отдельного cancel-объекта нет.
//

import Foundation

public protocol INetwork: Sendable {
    /// Сырые данные ответа.
    @discardableResult
    nonisolated func data(
        for endpoint: any IEndpoint,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws -> Data

    /// Ответ, декодированный в модель `T`.
    nonisolated func request<T: Decodable>(
        _ endpoint: any IEndpoint,
        as type: T.Type,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?,
        parser: (any IDataParser)?
    ) async throws -> T

    /// Запрос без интереса к телу ответа (пустой ответ = успех).
    nonisolated func send(
        _ endpoint: any IEndpoint,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws

    /// Загрузка сырых данных (raw body).
    @discardableResult
    nonisolated func upload(
        _ endpoint: any IEndpoint,
        data: Data,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws -> Data

    /// Multipart/form-data загрузка.
    @discardableResult
    nonisolated func upload(
        _ endpoint: any IEndpoint,
        multipart: MultipartFormData,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws -> Data
}

// MARK: - Convenience (параметры по умолчанию)

public extension INetwork {
    @discardableResult
    nonisolated func data(for endpoint: any IEndpoint) async throws -> Data {
        try await data(for: endpoint, interceptor: nil, validator: nil)
    }

    nonisolated func request<T: Decodable>(_ endpoint: any IEndpoint, as type: T.Type) async throws -> T {
        try await request(endpoint, as: type, interceptor: nil, validator: nil, parser: nil)
    }

    /// Вариант с выводом типа из контекста: `let user: User = try await network.request(endpoint)`.
    nonisolated func request<T: Decodable>(_ endpoint: any IEndpoint) async throws -> T {
        try await request(endpoint, as: T.self, interceptor: nil, validator: nil, parser: nil)
    }

    nonisolated func send(_ endpoint: any IEndpoint) async throws {
        try await send(endpoint, interceptor: nil, validator: nil)
    }

    @discardableResult
    nonisolated func upload(_ endpoint: any IEndpoint, multipart: MultipartFormData) async throws -> Data {
        try await upload(endpoint, multipart: multipart, interceptor: nil, validator: nil)
    }
}

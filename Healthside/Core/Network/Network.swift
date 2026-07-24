//
//  Network.swift
//  Healthside
//
//  Реализация сетевого слоя на URLSession + async/await.
//  Пайплайн одного запроса: adapt → выполнить → (retry?) → validate → (parse).
//

import Foundation

public nonisolated final class Network: INetwork {
    private let config: any INetworkConfig
    private let session: URLSession

    public init(config: any INetworkConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    // MARK: - INetwork

    @discardableResult
    public func data(
        for endpoint: any IEndpoint,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws -> Data {
        let request = try buildURLRequest(for: endpoint)
        return try await execute(request, uploadData: nil, interceptor: interceptor, validator: validator)
    }

    public func request<T: Decodable>(
        _ endpoint: any IEndpoint,
        as type: T.Type,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?,
        parser: (any IDataParser)?
    ) async throws -> T {
        guard let parser = parser ?? config.parser else { throw NetworkError.noParser }
        let data = try await data(for: endpoint, interceptor: interceptor, validator: validator)
        do {
            return try parser.parse(data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    public func send(
        _ endpoint: any IEndpoint,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws {
        _ = try await data(for: endpoint, interceptor: interceptor, validator: validator)
    }

    @discardableResult
    public func upload(
        _ endpoint: any IEndpoint,
        data uploadData: Data,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws -> Data {
        var request = try buildURLRequest(for: endpoint)
        request.httpBody = nil
        return try await execute(request, uploadData: uploadData, interceptor: interceptor, validator: validator)
    }

    @discardableResult
    public func upload(
        _ endpoint: any IEndpoint,
        multipart: MultipartFormData,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws -> Data {
        var request = try buildURLRequest(for: endpoint)
        request.httpBody = nil
        request.setValue(multipart.contentType, forHTTPHeaderField: "Content-Type")
        return try await execute(request, uploadData: multipart.encoded(), interceptor: interceptor, validator: validator)
    }

    // MARK: - Pipeline

    private func execute(
        _ request: URLRequest,
        uploadData: Data?,
        interceptor: (any IRequestInterceptor)?,
        validator: (any IRequestValidator)?
    ) async throws -> Data {
        let effectiveInterceptor = interceptor ?? config.interceptor
        let effectiveValidator = validator ?? config.validator ?? StatusCodeValidator()
        var retryCount = 0

        while true {
            try Task.checkCancellation()
            let adapted = try await effectiveInterceptor?.adapt(request) ?? request
            config.logger?.log(request: adapted)

            do {
                return try await performAttempt(adapted, uploadData: uploadData, validator: effectiveValidator)
            } catch is CancellationError {
                throw NetworkError.cancelled
            } catch {
                let mapped = Self.mapError(error)
                let action = await effectiveInterceptor?.retry(adapted, dueTo: mapped, retryCount: retryCount) ?? .doNotRetry
                guard case let .retry(delay) = action else {
                    config.logger?.log(response: nil, data: nil, for: adapted, error: mapped)
                    throw mapped
                }
                retryCount += 1
                if delay > 0 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
    }

    private func performAttempt(
        _ request: URLRequest,
        uploadData: Data?,
        validator: any IRequestValidator
    ) async throws -> Data {
        let data: Data
        let response: URLResponse
        if let uploadData {
            (data, response) = try await session.upload(for: request, from: uploadData)
        } else {
            (data, response) = try await session.data(for: request)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.nonHTTPResponse
        }
        config.logger?.log(response: http, data: data, for: request, error: nil)
        try validator.validate(request: request, response: http, data: data)
        return data
    }

    // MARK: - Building

    private func buildURLRequest(for endpoint: any IEndpoint) throws -> URLRequest {
        guard var components = URLComponents(string: fullURL(for: endpoint)) else {
            throw NetworkError.invalidURL
        }

        let headers = config.mergeHeaders(endpoint.headers)
        let parameters = config.mergeParameters(endpoint.parameters)

        // query-параметры
        if let parameters, !parameters.isEmpty, endpoint.encoding == .query {
            let items = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
            components.queryItems = (components.queryItems ?? []) + items
        }

        // тело: явный endpoint.body приоритетнее json-энкодинга параметров
        var body: Data? = endpoint.body
        if body == nil, let parameters, !parameters.isEmpty, endpoint.encoding == .json {
            body = try JSONSerialization.data(withJSONObject: parameters.mapValues { $0 as Any })
        }

        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = body
        request.timeoutInterval = endpoint.timeout ?? config.requestTimeout
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }

    private func fullURL(for endpoint: any IEndpoint) -> String {
        // Абсолютный путь в endpoint переопределяет baseURL.
        if let url = URL(string: endpoint.path), url.scheme != nil, url.host != nil {
            return endpoint.path
        }
        return config.baseURL() + endpoint.path
    }

    // MARK: - Error mapping

    private static func mapError(_ error: any Error) -> any Error {
        if error is NetworkError { return error }
        guard let urlError = error as? URLError else {
            return NetworkError.transport(error)
        }
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return NetworkError.offline
        case .timedOut:
            return NetworkError.timedOut
        case .cancelled:
            return NetworkError.cancelled
        default:
            return NetworkError.transport(urlError)
        }
    }
}

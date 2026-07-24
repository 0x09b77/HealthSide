//
//  CustomHeadersInterceptor.swift
//  Healthside
//
//  Добавляет фиксированный набор заголовков к запросу.
//

import Foundation

public nonisolated struct CustomHeadersInterceptor: IRequestInterceptor {
    private let headers: RequestHeaders

    public init(headers: RequestHeaders) {
        self.headers = headers
    }

    public nonisolated func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

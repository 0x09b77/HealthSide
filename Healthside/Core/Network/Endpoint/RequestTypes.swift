//
//  RequestTypes.swift
//  Healthside
//
//  Базовые типы сетевого слоя.
//

import Foundation

public nonisolated enum RequestMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public nonisolated enum RequestParameterEncoding: Sendable {
    /// Параметры уходят в query-строку URL.
    case query
    /// Параметры сериализуются в JSON-тело запроса.
    case json
}

public typealias RequestHeaders = [String: String]
public typealias RequestParameters = [String: any Sendable]

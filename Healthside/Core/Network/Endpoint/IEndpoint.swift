//
//  IEndpoint.swift
//  Healthside
//
//  Описывает конечную точку API. Значения по умолчанию — в extension.
//

import Foundation

public protocol IEndpoint: Sendable, CustomStringConvertible {
    nonisolated var path: String { get }
    nonisolated var method: RequestMethod { get }
    nonisolated var headers: RequestHeaders? { get }
    nonisolated var parameters: RequestParameters? { get }
    nonisolated var encoding: RequestParameterEncoding { get }
    nonisolated var timeout: TimeInterval? { get }
    /// Готовое тело запроса. Если задано — имеет приоритет над `parameters`.
    nonisolated var body: Data? { get }
}

public extension IEndpoint {
    nonisolated var headers: RequestHeaders? { nil }

    nonisolated var parameters: RequestParameters? { nil }

    nonisolated var encoding: RequestParameterEncoding {
        switch method {
        case .get, .delete: .query
        default: .json
        }
    }

    nonisolated var timeout: TimeInterval? { nil }

    nonisolated var body: Data? { nil }

    nonisolated var description: String { "\(method.rawValue) \(path)" }
}

//
//  APIError.swift
//  Healthside
//
//  Доменные ошибки API. Сервисы маппят сюда NetworkError и HTTP-коды.
//

import Foundation

public nonisolated enum APIError: LocalizedError, Equatable {
    case validation(reason: String?)
    case unauthorized
    case forbidden
    case notFound
    case conflict(reason: String?)
    case tooManyRequests
    case fileTooLarge
    case unsupportedMediaType
    case offline
    case timeout
    case server(reason: String?)
    case decoding
    case unknown

    public nonisolated var errorDescription: String? {
        switch self {
        case let .validation(reason): return reason ?? "Validation failed"
        case .unauthorized: return "Session expired. Please sign in again."
        case .forbidden: return "You don't have access to this resource."
        case .notFound: return "Not found."
        case let .conflict(reason): return reason ?? "Conflict."
        case .tooManyRequests: return "Too many requests. Try again later."
        case .fileTooLarge: return "This file is too large. The limit is 20 MB."
        case .unsupportedMediaType: return "Unsupported file type. Use a PDF, JPEG, PNG or HEIC."
        case .offline: return "No internet connection."
        case .timeout: return "Request timed out."
        case let .server(reason): return reason ?? "Server error."
        case .decoding: return "Unexpected response format."
        case .unknown: return "Something went wrong."
        }
    }
}

/// Тело ошибки бэкенда: `{ error: bool, reason: string }`.
nonisolated struct ServerErrorDTO: Decodable {
    let error: Bool?
    let reason: String?
}

enum APIErrorMapper {
    nonisolated static func map(_ error: any Error) -> APIError {
        if let apiError = error as? APIError { return apiError }
        guard let networkError = error as? NetworkError else { return .unknown }

        switch networkError {
        case .offline:
            return .offline
        case .timedOut:
            return .timeout
        case .decoding:
            return .decoding
        case let .invalidStatusCode(code, data):
            let reason = data
                .flatMap { try? JSONDecoder().decode(ServerErrorDTO.self, from: $0) }?
                .reason
            switch code {
            case 400: return .validation(reason: reason)
            case 401: return .unauthorized
            case 403: return .forbidden
            case 404: return .notFound
            case 409: return .conflict(reason: reason)
            case 413: return .fileTooLarge
            case 415: return .unsupportedMediaType
            case 429: return .tooManyRequests
            case 500...599: return .server(reason: reason)
            default: return .unknown
            }
        default:
            return .unknown
        }
    }
}

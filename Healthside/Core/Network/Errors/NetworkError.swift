//
//  NetworkError.swift
//  Healthside
//

import Foundation

public nonisolated enum NetworkError: LocalizedError {
    case invalidURL
    case offline
    case timedOut
    case cancelled
    case emptyResponse
    case noParser
    case nonHTTPResponse
    case invalidStatusCode(code: Int, data: Data?)
    case transport(any Error)
    case decoding(any Error)

    public nonisolated var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .offline:
            return "No internet connection"
        case .timedOut:
            return "Request timed out"
        case .cancelled:
            return "Request was cancelled"
        case .emptyResponse:
            return "Empty response"
        case .noParser:
            return "No parser configured for response"
        case .nonHTTPResponse:
            return "Response is not an HTTP response"
        case let .invalidStatusCode(code, _):
            return "Invalid HTTP status code: \(code)"
        case let .transport(error):
            return "Transport error: \(error.localizedDescription)"
        case let .decoding(error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

//
//  StatusCodeValidator.swift
//  Healthside
//

import Foundation

/// Валидатор по HTTP-кодам. По умолчанию успешными считаются 200..<300.
public nonisolated struct StatusCodeValidator: IRequestValidator {
    private let acceptableCodes: Set<Int>

    public init(acceptableCodes: Set<Int> = Set(200..<300)) {
        self.acceptableCodes = acceptableCodes
    }

    public nonisolated func validate(request: URLRequest?, response: HTTPURLResponse, data: Data) throws {
        guard acceptableCodes.contains(response.statusCode) else {
            throw NetworkError.invalidStatusCode(code: response.statusCode, data: data)
        }
    }
}

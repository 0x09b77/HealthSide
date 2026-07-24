//
//  IRequestValidator.swift
//  Healthside
//

import Foundation

/// Проверяет ответ на валидность. Бросает ошибку, если ответ невалиден.
public protocol IRequestValidator: Sendable {
    nonisolated func validate(request: URLRequest?, response: HTTPURLResponse, data: Data) throws
}

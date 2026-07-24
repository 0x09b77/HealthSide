//
//  IDataParser.swift
//  Healthside
//

import Foundation

/// Превращает сырые `Data` в модель.
public protocol IDataParser: Sendable {
    nonisolated func parse<Model: Decodable>(_ data: Data) throws -> Model
}

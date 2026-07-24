//
//  JSONParser.swift
//  Healthside
//

import Foundation

public nonisolated struct JSONParser: IDataParser {
    // Декодер создаётся фабрикой, чтобы тип оставался Sendable (JSONDecoder — класс).
    private let makeDecoder: @Sendable () -> JSONDecoder

    public init(makeDecoder: @escaping @Sendable () -> JSONDecoder = { JSONDecoder() }) {
        self.makeDecoder = makeDecoder
    }

    public nonisolated func parse<Model: Decodable>(_ data: Data) throws -> Model {
        try makeDecoder().decode(Model.self, from: data)
    }
}

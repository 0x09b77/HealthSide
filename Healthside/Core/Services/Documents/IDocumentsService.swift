//
//  IDocumentsService.swift
//  Healthside
//

import Foundation

public protocol IDocumentsService: Sendable {
    /// Лента обработки (newest first).
    nonisolated func list() async throws -> [DocumentDTO]

    /// Статус извлечения и (когда done) распарсенный конверт по id.
    nonisolated func document(id: String) async throws -> DocumentDTO
}

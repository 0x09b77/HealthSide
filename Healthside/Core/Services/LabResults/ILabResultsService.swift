//
//  ILabResultsService.swift
//  Healthside
//

import Foundation

public protocol ILabResultsService: Sendable {
    /// Загрузка файла (multipart). Возвращает id документа и статус (202).
    nonisolated func upload(
        fileData: Data,
        fileName: String,
        mimeType: String,
        label: String?
    ) async throws -> UploadAcceptedDTO

    /// Список своих результатов (newest first).
    nonisolated func list() async throws -> [LabResultDTO]

    /// Скачивание файла (owner only).
    nonisolated func download(id: String) async throws -> Data

    /// Удаление файла и метаданных (owner only, 204).
    nonisolated func delete(id: String) async throws
}

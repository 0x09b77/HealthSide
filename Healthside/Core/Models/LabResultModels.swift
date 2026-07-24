//
//  LabResultModels.swift
//  Healthside
//

import Foundation

/// Статус пайплайна извлечения данных из файла.
public nonisolated enum ParseStatus: String, Codable, Equatable, Sendable {
    case pending
    case processing
    case done
    case failed

    /// Разбор закончен — опрашивать больше нечего.
    public var isTerminal: Bool {
        switch self {
        case .done, .failed: true
        case .pending, .processing: false
        }
    }
}

public nonisolated struct LabResultDTO: Codable, Equatable, Sendable {
    public let id: String
    public let originalFilename: String
    public let mimeType: String
    public let fileSize: Int
    public let checksumSha256: String
    public let label: String?
    public let parseStatus: ParseStatus
    public let uploadedAt: Date?
}

/// Ответ 202 на загрузку файла.
public nonisolated struct UploadAcceptedDTO: Codable, Equatable, Sendable {
    public let documentId: String
    public let status: ParseStatus
}

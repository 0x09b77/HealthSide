//
//  DocumentModels.swift
//  Healthside
//

import Foundation

public nonisolated enum DocumentType: String, Codable, Equatable, Sendable {
    case labPanel = "lab_panel"
    case imagingReport = "imaging_report"
    case consultNote = "consult_note"
    case other

    public var displayName: String {
        switch self {
        case .labPanel: "Lab panel"
        case .imagingReport: "Imaging report"
        case .consultNote: "Consult note"
        case .other: "Document"
        }
    }
}

/// Документ в ленте обработки: статус + (когда done) распарсенный конверт.
public nonisolated struct DocumentDTO: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let status: ParseStatus
    public let originalFilename: String
    public let mimeType: String
    public let fileSize: Int
    public let label: String?
    public let documentType: DocumentType?
    public let reportDate: Date?
    public let provider: String?
    public let summary: String?
    public let diagnosis: String?
    public let payloadJson: JSONValue?
    public let uploadedAt: Date?
}

public extension DocumentDTO {
    /// Заголовок для списков: метка → тип → имя файла.
    nonisolated var displayTitle: String {
        if let label, !label.isEmpty { return label }
        return documentType?.displayName ?? originalFilename
    }

    /// Подзаголовок: провайдер · дата.
    nonisolated var displaySubtitle: String {
        let date = (reportDate ?? uploadedAt)?.formatted(.dateTime.month(.abbreviated).day())
        return [provider, date].compactMap { $0 }.joined(separator: " · ")
    }
}

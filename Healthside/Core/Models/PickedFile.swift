//
//  PickedFile.swift
//  Healthside
//
//  Файл, выбранный пользователем (камера/галерея/файлы), готовый к multipart-загрузке.
//  Тип определяем по magic bytes — как и бэкенд (он игнорирует расширение и Content-Type).
//

import Foundation

public nonisolated struct PickedFile: Equatable, Sendable {
    public let data: Data
    public let fileName: String
    public let mimeType: String

    public init(data: Data, fileName: String, mimeType: String) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }

    /// Собирает файл, определяя тип по содержимому. nil — тип не поддерживается.
    public init?(data: Data, suggestedName: String?) {
        guard let mimeType = FileSniffer.mimeType(of: data) else { return nil }
        self.data = data
        self.mimeType = mimeType
        if let suggestedName, !suggestedName.isEmpty {
            self.fileName = suggestedName
        } else {
            let stamp = Date.now.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits))
                .replacingOccurrences(of: "/", with: "-")
            self.fileName = "Scan \(stamp).\(FileSniffer.fileExtension(for: mimeType))"
        }
    }

    public var byteSize: Int { data.count }

    public var displaySize: String {
        ByteCountFormatter.string(fromByteCount: Int64(byteSize), countStyle: .file)
    }
}

public nonisolated enum FileSniffer {
    /// Поддерживаемые бэкендом типы: PDF, JPEG, PNG, HEIC.
    public static func mimeType(of data: Data) -> String? {
        if data.starts(with: [0x25, 0x50, 0x44, 0x46]) { return "application/pdf" }
        if data.starts(with: [0xFF, 0xD8, 0xFF]) { return "image/jpeg" }
        if data.starts(with: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) { return "image/png" }
        if isHEIC(data) { return "image/heic" }
        return nil
    }

    public static func fileExtension(for mimeType: String) -> String {
        switch mimeType {
        case "application/pdf": "pdf"
        case "image/jpeg": "jpg"
        case "image/png": "png"
        case "image/heic": "heic"
        default: "bin"
        }
    }

    /// HEIC: ISO-BMFF box `ftyp` с брендом heic/heix/hevc/mif1 на смещении 4.
    private static func isHEIC(_ data: Data) -> Bool {
        guard data.count >= 12 else { return false }
        let box = data.subdata(in: 4..<12)
        guard let marker = String(data: box, encoding: .ascii) else { return false }
        guard marker.hasPrefix("ftyp") else { return false }
        let brand = String(marker.dropFirst(4))
        return ["heic", "heix", "hevc", "mif1", "heim", "heis"].contains(brand)
    }
}

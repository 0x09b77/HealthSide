//
//  MultipartFormData.swift
//  Healthside
//
//  Сборка тела multipart/form-data. Пример (загрузка анализа):
//
//      var form = MultipartFormData()
//      form.addField(name: "type", value: "lab_result")
//      form.addFile(name: "file", fileName: "result.pdf", mimeType: "application/pdf", data: pdfData)
//      let response = try await network.upload(endpoint, multipart: form)
//

import Foundation

public nonisolated struct MultipartFormData: Sendable {
    public let boundary: String
    private var body = Data()

    public init(boundary: String = "Boundary-\(UUID().uuidString)") {
        self.boundary = boundary
    }

    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    /// Текстовое поле формы.
    public mutating func addField(name: String, value: String) {
        var part = "--\(boundary)\r\n"
        part += "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
        part += "\(value)\r\n"
        body.append(Data(part.utf8))
    }

    /// Файл (бинарные данные).
    public mutating func addFile(name: String, fileName: String, mimeType: String, data: Data) {
        var header = "--\(boundary)\r\n"
        header += "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n"
        header += "Content-Type: \(mimeType)\r\n\r\n"
        body.append(Data(header.utf8))
        body.append(data)
        body.append(Data("\r\n".utf8))
    }

    /// Итоговое тело с завершающим boundary.
    public func encoded() -> Data {
        var data = body
        data.append(Data("--\(boundary)--\r\n".utf8))
        return data
    }
}

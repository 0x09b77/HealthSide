//
//  BiomarkerRow.swift
//  Healthside
//
//  Вью-модель биомаркера. Извлекается best-effort из payloadJson (envelope),
//  т.к. в API payloadJson — opaque object. Если структура другая — секция скрыта.
//

import Foundation

public nonisolated enum BiomarkerStatus: Sendable, Equatable {
    case normal
    case high
    case low
    case critical
    case unknown

    init(raw: String?) {
        switch raw?.lowercased() {
        case "normal": self = .normal
        case "high": self = .high
        case "low": self = .low
        case "critical": self = .critical
        default: self = .unknown
        }
    }

    /// Значение вне нормы — такие маркеры поднимаем в «worth watching».
    public var needsAttention: Bool {
        switch self {
        case .high, .low, .critical: true
        case .normal, .unknown: false
        }
    }
}

public nonisolated struct BiomarkerRow: Identifiable, Equatable, Sendable {
    public var id: String { name }
    public let name: String
    public let rawValue: String?
    public let numericValue: Double?
    public let unit: String?
    public let referenceLow: Double?
    public let referenceHigh: Double?
    public let status: BiomarkerStatus

    /// Значение с единицами для отображения.
    public var value: String {
        let number = numericValue.map(BiomarkerRow.format) ?? rawValue
        return [number, unit].compactMap { $0 }.joined(separator: " ")
    }

    public static func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }

    /// Разбирает `payloadJson.biomarkers` в строки. Пустой массив, если поля нет.
    public static func rows(from payload: JSONValue?) -> [BiomarkerRow] {
        guard let items = payload?["biomarkers"]?.arrayValue else { return [] }
        return items.compactMap { item in
            guard let name = item["name"]?.stringValue, !name.isEmpty else { return nil }
            return BiomarkerRow(
                name: name,
                rawValue: item["value"]?.stringValue,
                numericValue: item["value"]?.numberValue,
                unit: item["unit"]?.stringValue,
                referenceLow: item["reference_low"]?.numberValue ?? item["referenceLow"]?.numberValue,
                referenceHigh: item["reference_high"]?.numberValue ?? item["referenceHigh"]?.numberValue,
                status: BiomarkerStatus(raw: item["status"]?.stringValue)
            )
        }
    }
}

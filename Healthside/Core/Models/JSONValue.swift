//
//  JSONValue.swift
//  Healthside
//
//  Тип-безопасное представление произвольного JSON (для DocumentDTO.payloadJson).
//

import Foundation

public nonisolated enum JSONValue: Codable, Equatable, Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value): try container.encode(value)
        case let .number(value): try container.encode(value)
        case let .bool(value): try container.encode(value)
        case let .object(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
}

public extension JSONValue {
    /// Доступ к полю объекта.
    nonisolated subscript(key: String) -> JSONValue? {
        if case let .object(object) = self { return object[key] }
        return nil
    }

    /// Строковое представление (строка или число).
    nonisolated var stringValue: String? {
        switch self {
        case let .string(value):
            return value
        case let .number(value):
            return value == value.rounded() ? String(Int(value)) : String(value)
        default:
            return nil
        }
    }

    nonisolated var arrayValue: [JSONValue]? {
        if case let .array(array) = self { return array }
        return nil
    }

    /// Числовое значение (число или строка с числом).
    nonisolated var numberValue: Double? {
        switch self {
        case let .number(value): return value
        case let .string(value): return Double(value)
        default: return nil
        }
    }
}

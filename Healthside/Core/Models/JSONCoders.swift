//
//  JSONCoders.swift
//  Healthside
//
//  Общий декодер: даты API приходят в ISO8601 (date-time) или как date (yyyy-MM-dd).
//

import Foundation

public extension JSONDecoder {
    nonisolated static var healthside: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            for formatter in dateFormatters {
                if let date = formatter.date(from: string) {
                    return date
                }
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date format: \(string)"
            )
        }
        return decoder
    }

    private nonisolated static let dateFormatters: [DateFormatter] = {
        let isoFractional = DateFormatter()
        isoFractional.locale = Locale(identifier: "en_US_POSIX")
        isoFractional.timeZone = TimeZone(identifier: "UTC")
        isoFractional.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        let iso = DateFormatter()
        iso.locale = Locale(identifier: "en_US_POSIX")
        iso.timeZone = TimeZone(identifier: "UTC")
        iso.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        let dateOnly = DateFormatter()
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.timeZone = TimeZone(identifier: "UTC")
        dateOnly.dateFormat = "yyyy-MM-dd"

        return [isoFractional, iso, dateOnly]
    }()
}

//
//  BiomarkerSeries.swift
//  Healthside
//
//  Тренд одного биомаркера во времени. Эндпоинта трендов в API нет, поэтому
//  серии собираем на клиенте: биомаркеры из payloadJson каждого документа
//  + дата документа. Немодифицируемые серии — производные от списка документов.
//

import Foundation

public nonisolated struct BiomarkerMeasurement: Identifiable, Equatable, Sendable {
    public var id: String { documentId }
    public let value: Double
    public let status: BiomarkerStatus
    public let date: Date
    public let documentId: String
    public let documentTitle: String
}

public nonisolated struct BiomarkerSeries: Identifiable, Equatable, Sendable {
    public nonisolated enum Trend: Sendable, Equatable {
        case up
        case down
        case stable
        case unknown
    }

    public var id: String { name }
    public let name: String
    public let unit: String?
    public let referenceLow: Double?
    public let referenceHigh: Double?
    /// Отсортированы от старых к новым.
    public let measurements: [BiomarkerMeasurement]

    public var latest: BiomarkerMeasurement? { measurements.last }
    public var previous: BiomarkerMeasurement? { measurements.dropLast().last }

    public var trend: Trend {
        guard let latest, let previous else { return .unknown }
        if latest.value > previous.value { return .up }
        if latest.value < previous.value { return .down }
        return .stable
    }

    public var status: BiomarkerStatus { latest?.status ?? .unknown }
    public var needsAttention: Bool { status.needsAttention }

    public var displayValue: String {
        guard let latest else { return "—" }
        return [BiomarkerRow.format(latest.value), unit].compactMap { $0 }.joined(separator: " ")
    }

    public var hasReferenceRange: Bool {
        referenceLow != nil && referenceHigh != nil
    }

    /// Собирает серии по всем разобранным документам. Ключ — имя маркера.
    public static func series(from documents: [DocumentDTO]) -> [BiomarkerSeries] {
        var measurements: [String: [BiomarkerMeasurement]] = [:]
        var info: [String: BiomarkerRow] = [:]

        for document in documents where document.status == .done {
            guard let date = document.reportDate ?? document.uploadedAt else { continue }

            for row in BiomarkerRow.rows(from: document.payloadJson) {
                guard let value = row.numericValue else { continue }
                let key = row.name.lowercased()
                measurements[key, default: []].append(
                    BiomarkerMeasurement(
                        value: value,
                        status: row.status,
                        date: date,
                        documentId: document.id,
                        documentTitle: document.displayTitle
                    )
                )
                // Документы приходят newest-first — единицы/референс берём из свежего.
                if info[key] == nil { info[key] = row }
            }
        }

        return measurements.compactMap { key, points -> BiomarkerSeries? in
            guard let row = info[key] else { return nil }
            return BiomarkerSeries(
                name: row.name,
                unit: row.unit,
                referenceLow: row.referenceLow,
                referenceHigh: row.referenceHigh,
                measurements: points.sorted { $0.date < $1.date }
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

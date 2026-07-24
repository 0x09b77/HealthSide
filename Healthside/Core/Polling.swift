//
//  Polling.swift
//  Healthside
//
//  Расписание fallback-опроса статуса разбора (основной канал — пуш).
//  Экспоненциальный бэкофф: 2 · 4 · 8 · 16 · 30 · 30… секунд.
//

import Foundation

public nonisolated enum Polling {
    /// Потолок попыток, чтобы «зависший» pending не опрашивался вечно.
    public static let maxAttempts = 20

    public static func delay(attempt: Int) -> Duration {
        let seconds = min(2 * pow(2, Double(max(attempt, 1) - 1)), 30)
        return .seconds(seconds)
    }
}

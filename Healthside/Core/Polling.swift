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

    /// Общий цикл: `fetch` с бэкоффом, пока `isTerminal(value)` не станет true.
    /// Каждый успешный/неуспешный результат уходит через `onResult`. Обрывается
    /// при отмене (эффект привязан к `.task` вью — см. вызывающие фичи), ошибке
    /// или исчерпании `maxAttempts`.
    public static func run<T>(
        clock: any Clock<Duration>,
        fetch: () async throws -> T,
        isTerminal: (T) -> Bool,
        onResult: (Result<T, APIError>) async -> Void
    ) async throws {
        var attempt = 0
        while !Task.isCancelled, attempt <= maxAttempts {
            if attempt > 0 {
                try await clock.sleep(for: delay(attempt: attempt))
            }
            do {
                let value = try await fetch()
                await onResult(.success(value))
                if isTerminal(value) { return }
            } catch {
                await onResult(.failure(error as? APIError ?? .unknown))
                return
            }
            attempt += 1
        }
    }
}

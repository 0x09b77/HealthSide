//
//  NetworkLogger.swift
//  Healthside
//
//  ВАЖНО: не логируем тела запросов/ответов и query — там может быть PHI.
//  Только метод, host+path и статус-код. См. доку Security-Privacy.
//

import Foundation
import OSLog

public nonisolated struct NetworkLogger: INetworkLogger {
    private let logger: Logger

    public init(subsystem: String = "app.healthside", category: String = "Network") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public nonisolated func log(request: URLRequest) {
        let method = request.httpMethod ?? "?"
        let path = request.url?.path ?? "?"
        logger.debug("→ \(method, privacy: .public) \(path, privacy: .private)")
    }

    public nonisolated func log(response: HTTPURLResponse?, data: Data?, for request: URLRequest, error: (any Error)?) {
        let method = request.httpMethod ?? "?"
        let path = request.url?.path ?? "?"
        if let error {
            logger.error("✗ \(method, privacy: .public) \(path, privacy: .private) — \(error.localizedDescription, privacy: .public)")
        } else {
            logger.debug("← \(response?.statusCode ?? 0, privacy: .public) \(method, privacy: .public) \(path, privacy: .private)")
        }
    }
}

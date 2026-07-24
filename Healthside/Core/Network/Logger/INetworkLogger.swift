//
//  INetworkLogger.swift
//  Healthside
//

import Foundation

public protocol INetworkLogger: Sendable {
    nonisolated func log(request: URLRequest)
    nonisolated func log(response: HTTPURLResponse?, data: Data?, for request: URLRequest, error: (any Error)?)
}

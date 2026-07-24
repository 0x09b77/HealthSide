//
//  IBaseUrlProvider.swift
//  Healthside
//
//  Провайдер базового URL по окружению.
//

import Foundation

public nonisolated enum NetworkEnvironment: Sendable, Equatable {
    case qa
    case preprod
    case prod
    case custom(String)
}

public protocol IBaseUrlProvider: Sendable {
    nonisolated static func baseURL(for environment: NetworkEnvironment) -> String
}

//
//  StaticBaseUrlProvider.swift
//  Healthside
//
//  TODO: заменить домены на реальные.
//

import Foundation

public enum StaticBaseUrlProvider: IBaseUrlProvider {
    public nonisolated static func baseURL(for environment: NetworkEnvironment) -> String {
        switch environment {
        case .qa:
            return "https://api.qa.healthside.app"
        case .preprod:
            return "https://api.preprod.healthside.app"
        case .prod:
            return "https://api.healthside.app"
        case let .custom(url):
            return url
        }
    }
}

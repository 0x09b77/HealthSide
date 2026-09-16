//
//  NetworkDependency.swift
//  Healthside
//
//  Регистрация сетевого слоя в TCA-DI. Это транспорт; поверх него живёт APIClient
//  (см. доку Networking-and-Firebase.md) со своими эндпоинтами и маппингом ошибок.
//

import ComposableArchitecture
import Foundation

private nonisolated enum NetworkKey: DependencyKey {
    static let liveValue: any INetwork = Network(
        config: NetworkConfig(
            provider: StaticBaseUrlProvider.self,
            environment: .prod,
            interceptor: AuthInterceptor(),
            parser: JSONParser(makeDecoder: { .healthside }),
            logger: NetworkLogger()
        )
    )

    // TODO: заменить на unimplemented-заглушку, чтобы ловить незамоканные зависимости в тестах.
    static let testValue: any INetwork = liveValue
}

public extension DependencyValues {
    nonisolated var network: any INetwork {
        get { self[NetworkKey.self] }
        set { self[NetworkKey.self] = newValue }
    }
}

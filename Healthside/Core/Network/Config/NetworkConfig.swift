//
//  NetworkConfig.swift
//  Healthside
//

import Foundation

public nonisolated struct NetworkConfig: INetworkConfig {
    public let baseURL: @Sendable () -> String
    public let commonHeaders: RequestHeaders?
    public let commonParameters: RequestParameters?
    public let requestTimeout: TimeInterval
    public let interceptor: (any IRequestInterceptor)?
    public let validator: (any IRequestValidator)?
    public let parser: (any IDataParser)?
    public let logger: (any INetworkLogger)?

    public init(
        baseURL: @autoclosure @escaping @Sendable () -> String,
        commonHeaders: RequestHeaders? = nil,
        commonParameters: RequestParameters? = nil,
        requestTimeout: TimeInterval = 30,
        interceptor: (any IRequestInterceptor)? = nil,
        validator: (any IRequestValidator)? = StatusCodeValidator(),
        parser: (any IDataParser)? = JSONParser(),
        logger: (any INetworkLogger)? = nil
    ) {
        self.baseURL = baseURL
        self.commonHeaders = commonHeaders
        self.commonParameters = commonParameters
        self.requestTimeout = requestTimeout
        self.interceptor = interceptor
        self.validator = validator
        self.parser = parser
        self.logger = logger
    }

    /// Удобный init: базовый URL берётся из провайдера по окружению.
    public init(
        provider: any IBaseUrlProvider.Type,
        environment: @autoclosure @escaping @Sendable () -> NetworkEnvironment,
        commonHeaders: RequestHeaders? = nil,
        commonParameters: RequestParameters? = nil,
        requestTimeout: TimeInterval = 30,
        interceptor: (any IRequestInterceptor)? = nil,
        validator: (any IRequestValidator)? = StatusCodeValidator(),
        parser: (any IDataParser)? = JSONParser(),
        logger: (any INetworkLogger)? = nil
    ) {
        self.init(
            baseURL: provider.baseURL(for: environment()),
            commonHeaders: commonHeaders,
            commonParameters: commonParameters,
            requestTimeout: requestTimeout,
            interceptor: interceptor,
            validator: validator,
            parser: parser,
            logger: logger
        )
    }
}

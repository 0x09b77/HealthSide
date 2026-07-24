//
//  AuthEndpoint.swift
//  Healthside
//
//  POST /auth/{register,login,refresh,logout}. Без авторизации (security: []).
//

import Foundation

enum AuthEndpoint: IEndpoint {
    case register(Data)
    case login(Data)
    case refresh(Data)
    case logout(Data)

    var path: String {
        switch self {
        case .register: "/auth/register"
        case .login: "/auth/login"
        case .refresh: "/auth/refresh"
        case .logout: "/auth/logout"
        }
    }

    var method: RequestMethod { .post }

    var body: Data? {
        switch self {
        case let .register(data), let .login(data), let .refresh(data), let .logout(data):
            data
        }
    }
}

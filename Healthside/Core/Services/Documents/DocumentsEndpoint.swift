//
//  DocumentsEndpoint.swift
//  Healthside
//

import Foundation

enum DocumentsEndpoint: IEndpoint {
    case list
    case get(id: String)

    var path: String {
        switch self {
        case .list: "/documents"
        case let .get(id): "/documents/\(id)"
        }
    }

    var method: RequestMethod { .get }
}

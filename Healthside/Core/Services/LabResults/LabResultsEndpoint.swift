//
//  LabResultsEndpoint.swift
//  Healthside
//

import Foundation

enum LabResultsEndpoint: IEndpoint {
    case upload
    case list
    case download(id: String)
    case delete(id: String)

    var path: String {
        switch self {
        case .upload, .list: "/lab-results"
        case let .download(id), let .delete(id): "/lab-results/\(id)"
        }
    }

    var method: RequestMethod {
        switch self {
        case .upload: .post
        case .list, .download: .get
        case .delete: .delete
        }
    }
}

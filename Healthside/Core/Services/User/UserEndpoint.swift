//
//  UserEndpoint.swift
//  Healthside
//

import Foundation

enum UserEndpoint: IEndpoint {
    case me

    var path: String { "/me" }
    var method: RequestMethod { .get }
}

//
//  AuthorizationAccessTokenResponse.swift
//
//
//  Created by v.maltsev on 22.08.2023.
//

import Foundation
import RestClient

struct AuthorizationAccessTokenResponse: JSONDecodableBody {
    let accessToken: String
    let expiresIn: TimeInterval
    let scope: String

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

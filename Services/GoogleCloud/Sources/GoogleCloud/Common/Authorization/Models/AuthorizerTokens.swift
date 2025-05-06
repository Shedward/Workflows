//
//  AuthorizerTokens.swift
//
//
//  Created by v.maltsev on 22.08.2023.
//

import Foundation
import Prelude

struct AccessToken: Codable {
    let token: String
    let scopes: [String]

    init(from response: AuthorizationAccessTokenResponse) {
        self.token = response.accessToken
        self.scopes = response.scope.split(separator: " ").map(String.init)
    }
}

struct RefreshToken: Codable {
    let token: String

    init(from response: AuthorizationRefreshTokenResponse) {
        self.token = response.refreshToken
    }
}

struct AuthorizerTokens: Codable {
    var accessToken: Expiring<AccessToken>?
    var refreshToken: Expiring<RefreshToken>?
}

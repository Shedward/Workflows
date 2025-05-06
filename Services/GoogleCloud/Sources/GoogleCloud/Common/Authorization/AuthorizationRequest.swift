//
//  AuthorizerRequest.swift
//
//
//  Created by v.maltsev on 22.08.2023.
//

public struct AuthorizerRequest: Decodable {
    public let clientId: String
    public let scopes: [String]
    public let redirectUri: String

    public init(clientId: String, scopes: [String], redirectUri: String) {
        self.clientId = clientId
        self.scopes = scopes
        self.redirectUri = redirectUri
    }
}

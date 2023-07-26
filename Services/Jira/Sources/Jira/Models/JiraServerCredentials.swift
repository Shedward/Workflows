//
//  JiraServerCredentials.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Foundation
import Prelude

public struct JiraServerCredentials: Codable {
    public var username: String
    public var password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    func token() throws -> String {
        let credsString = "\(username):\(password)"
        guard let data = credsString.data(using: .utf8) else {
            throw Failure("Failed to convert JiraCredentials to data string")
        }
        let token = data.base64EncodedString()
        return token
    }
}

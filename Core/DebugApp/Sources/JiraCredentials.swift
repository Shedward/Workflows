//
//  JiraCredentials.swift
//  Created by Vladislav Maltsev on 24.07.2023.
//

import Foundation
import Prelude

struct JiraCredentials: Codable {
    let username: String
    let password: String

    func token() throws -> String {
        guard let token = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
            throw Failure("Failed to convert jira creds to token")
        }

        return token
    }
}

//
//  JiraAuthorizer.swift
//
//
//  Created by v.maltsev on 03.09.2023.
//

import Foundation
import Prelude

public class JiraAuthorizer {
    private let credentialsStorage: ThrowingAccessor<Data?>

    public init(credentialsStorage: ThrowingAccessor<Data?>) {
        self.credentialsStorage = credentialsStorage
    }
    
    public func isAuthorized() -> Bool {
        (try? credentialsStorage.get()) != nil
    }

    public func saveCredentials(_ creds: JiraServerCredentials) throws {
        let data = try Failure.wrap("Encoding Jira creds") {
            try JSONEncoder().encode(creds)
        }

        try Failure.wrap("Saving Jira creds") {
            try credentialsStorage.set(data)
        }
    }

    public func logout() throws {
        try credentialsStorage.set(nil)
    }

    func creds() throws -> JiraServerCredentials {
        let data = try Failure.wrap("Loading Jira creds") {
            try credentialsStorage.get()
        }

        guard let data else {
            throw AuthorizerError.signInRequired
        }

        let creds = try Failure.wrap("Decoding Jira creds") {
            try JSONDecoder().decode(JiraServerCredentials.self, from: data)
        }

        return creds
    }
}

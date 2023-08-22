//
//  Dependencies.swift
//
//
//  Created by v.maltsev on 23.08.2023.
//

import SecureStorage
import GoogleCloud
import Foundation

final class Dependencies {
    static var shared = Dependencies()

    init() {
    }

    lazy var secureStorage: SecItemStorage = {
        SecItemStorage<Accounts>(service: "me.workflows.OAuthHelper")
    }()

    lazy var googleAuthorizer: GoogleCloud.Authorizer = {
        let request = AuthorizerRequest(
            clientId: "546377572292-380otnito02mdjd4vhacgheri475f482.apps.googleusercontent.com",
            scopes: [
                "https://www.googleapis.com/auth/drive",
                "https://www.googleapis.com/auth/spreadsheets"
            ],
            redirectUri: "com.googleusercontent.apps.546377572292-380otnito02mdjd4vhacgheri475f482:oauth-redirect"
        )
        let tokenStorage = secureStorage.accessor(for: .google)
        return GoogleCloud.Authorizer(request: request, tokensStorage: tokenStorage)
    }()
}

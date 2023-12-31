//
//  Dependencies.swift
//
//
//  Created by v.maltsev on 23.08.2023.
//

import SecureStorage
import LocalStorage
import GoogleCloud
import Foundation

final class Dependencies {
    static var shared = Dependencies()

    init() {
    }

    lazy var secureStorage: SecItemStorage = {
        SecItemStorage<Accounts>(service: "me.workflows.Workflows")
    }()

    lazy var configStorage: CodableStorage = {
        DirectoryCodableStorage()
    }()

    lazy var googleAuthorizer: GoogleAuthorizer = {
        let request = try! configStorage.load(GoogleCloud.AuthorizerRequest.self, at: "google")
        let tokenStorage = secureStorage.accessor(for: .google)
        return GoogleAuthorizer(request: request, tokensStorage: tokenStorage)
    }()
}

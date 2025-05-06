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
import FileSystem

final class Dependencies {
    static var shared = Dependencies()

    let googleAuthorizer: GoogleAuthorizer

    init() {
        let filesystem = FileManagerFileSystem()
        let secureStorage = SecItemStorage<Accounts>(service: "me.workflows.Workflows")
        let configStorage = DirectoryCodableStorage(at: filesystem.homeDirectory().appending(".workflows"))

        let request = try! configStorage.load(GoogleCloud.AuthorizerRequest.self, at: "google")
        let tokenStorage = secureStorage.accessor(for: .google)
        self.googleAuthorizer = GoogleAuthorizer(request: request, tokensStorage: tokenStorage)
    }
}

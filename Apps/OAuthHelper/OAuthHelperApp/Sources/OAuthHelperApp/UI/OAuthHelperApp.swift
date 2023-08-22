//
//  OAuthHelperApp.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import SwiftUI
import os

public struct OAuthHelperApp: View {

    public init() {
    }

    public var body: some View {
        HStack(spacing: 16) {
            OAuthServiceView(
                icon: Image("services.google", bundle: .module),
                name: "Google",
                onSignIn: {
                    Task {
                        do {
                            let url = try await Dependencies.shared.googleAuthorizer.authorizationUrl()
                            NSWorkspace.shared.open(url)
                        } catch {
                            Logger(scope: .global).fault("Failed to open url: \(error, privacy: .public)")
                        }
                    }
                }
            )
            OAuthServiceView(
                icon: Image("services.jira", bundle: .module),
                name: "Jira",
                onSignIn: { }
            )
            OAuthServiceView(
                icon: Image("services.github", bundle: .module),
                name: "Github",
                onSignIn: { }
            )
        }
        .padding(16)
    }
}

#Preview {
    OAuthHelperApp()
}

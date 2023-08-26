//
//  OAuthHelperApp.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import SwiftUI
import os
import GoogleCloud

public struct OAuthHelperApp: View {

    private let googleAuthorizer = Dependencies.shared.googleAuthorizer

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
                            let url = try await googleAuthorizer.authorizationUrl()
                            NSWorkspace.shared.open(url)
                        } catch {
                            Logger(scope: .global).fault("Failed to open url: \(error, privacy: .public)")
                        }
                    }
                },
                fetchStatus: {
                    let isAuthorized = await googleAuthorizer.isAuthorized()
                    if !isAuthorized {
                        return .unauthorized
                    }

                    let exrirationTime = await googleAuthorizer.authorizedUntil()
                    return .authorized(" Until \(exrirationTime?.timeIntervalSinceNow ?? 0)")
                }
            )
            OAuthServiceView(
                icon: Image("services.jira", bundle: .module),
                name: "Jira",
                onSignIn: { },
                fetchStatus: {
                    .unknown
                }
            )
            OAuthServiceView(
                icon: Image("services.github", bundle: .module),
                name: "Github",
                onSignIn: { },
                fetchStatus: {
                    .unknown
                }
            )
        }
        .padding(16)
    }
}

#Preview {
    OAuthHelperApp()
}

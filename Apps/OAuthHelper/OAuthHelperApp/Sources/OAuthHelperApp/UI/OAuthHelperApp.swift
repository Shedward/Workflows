//
//  OAuthHelperApp.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import SwiftUI

public struct OAuthHelperApp: View {

    public init() {
    }

    public var body: some View {
        HStack(spacing: 16) {
            OAuthServiceView(
                icon: Image("services.google", bundle: .module),
                name: "Google",
                onSignIn: { }
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

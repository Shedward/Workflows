//
//  OAuthServiceView.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import SwiftUI
import Prelude

struct OAuthServiceView: View {
    let icon: Image
    let name: String
    let onSignIn: () -> Void
    let fetchStatus: () async throws -> OAuthStatus

    @State
    private var authStatus: Loading<OAuthStatus, Error>  = .loading

    var body: some View {
        VStack {
            icon
            Text(name)
                .font(.title)
            Spacer(minLength: 8)
            authorizationStatusView
        }
        .frame(width: 100)
        .padding()
        .background(Rectangle().fill(Color.white))
        .onAppear(perform: loadStatus)
    }

    @ViewBuilder
    var authorizationStatusView: some View {
        switch authStatus {
        case .loading:
            Text("Loading")
        case .loaded(.unknown):
            Text("-")
        case .loaded(.unauthorized):
            VStack {
                Image(systemName: "key.fill")
                    .font(.title)
                FixedSpacer(height: 8)
                Text("Not authorized")
                    .font(.caption)
                FixedSpacer(height: 24)
                Button("Sign in", action: onSignIn)
            }
        case .loaded(.authorized(let message)):
            VStack {
                Text("Authorized")
                Text(message)
            }
        case .failure(let error):
            VStack {
                Text("Failed")
                Text("\(error.localizedDescription)")
                Button("Retry", action: loadStatus)
            }
        }
    }

    private func loadStatus() {
        Task { @MainActor in
            authStatus = .loading
            do {
                let newStatus = try await fetchStatus()
                authStatus = .loaded(newStatus)
            } catch {
                authStatus = .failure(error)
            }
        }
    }
}

#Preview {
    OAuthServiceView(
        icon: Image("services.google", bundle: .module),
        name: "Google",
        onSignIn: { },
        fetchStatus: { .unauthorized }
    )
}

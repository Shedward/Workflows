//
//  OAuthServiceView.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import SwiftUI

struct OAuthServiceView: View {
    let icon: Image
    let name: String
    let onSignIn: () -> Void

    var body: some View {
        VStack {
            icon
            Text(name)
                .font(.title)
            Spacer(minLength: 8)
            VStack {
                Image(systemName: "key.fill")
                    .font(.title)
                FixedSpacer(height: 8)
                Text("Not authorized")
                    .font(.caption)
                FixedSpacer(height: 24)
                Button("Sign in", action: onSignIn)
            }
            .foregroundStyle(Color(.systemRed))
        }
        .frame(width: 100)
        .padding()
        .background(Rectangle().fill(Color.white))
    }
}

#Preview {
    OAuthServiceView(
        icon: Image("services.google", bundle: .module),
        name: "Google",
        onSignIn: { }
    )
}

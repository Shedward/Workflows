//
//  OAuthHelpers.swift
//  GoogleServices
//

import Foundation

// MARK: - base64url encoding

extension Data {
    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: - Form encoding

func formEncode(_ params: [String: String]) -> String {
    params
        .map { "\($0.key)=\(percentEncode($0.value))" }
        .joined(separator: "&")
}

private func percentEncode(_ string: String) -> String {
    string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
}

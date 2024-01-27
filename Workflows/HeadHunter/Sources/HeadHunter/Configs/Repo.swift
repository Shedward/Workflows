//
//  Repo.swift
//
//
//  Created by Vlad Maltsev on 20.01.2024.
//

import Foundation

public enum Repo: String, Codable {
    case iosApps = "ios-apps"
}

public struct RepoDetails: Codable {
    public let name: Repo
    public let ssh: String
    public let url: URL
}

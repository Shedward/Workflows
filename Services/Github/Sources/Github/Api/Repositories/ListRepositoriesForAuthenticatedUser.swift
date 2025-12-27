//
//  List.swift
//  Github
//
//  Created by Vlad Maltsev on 23.12.2025.
//

import Core
import RestClient

// https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-the-authenticated-user
public struct ListRepositoriesForAuthenticatedUser: GithubApi {
    public var visibility: Visibility?
    public var affiliation: Affiliation?
    public var type: `Type`?

    public var request: RouteRequest {
        Request(.get, "/user/repos")
            .query(
                .set("visibility", to: visibility)
                .set("affiliation", to: affiliation)
                .set("type", to: type)
            )
            .authorised(true)
    }

    public init(visibility: Visibility? = nil, affiliation: Affiliation? = nil, type: Type? = nil) {
        self.visibility = visibility
        self.affiliation = affiliation
        self.type = type
    }
}

extension ListRepositoriesForAuthenticatedUser {
    public enum Visibility: String, QueryConvertible {
        case all
        case `public`
        case `private`
    }

    public enum Affiliation: String, QueryConvertible {
        case owner
        case collaborator
        case organizationMember = "organization_member"
    }

    public enum `Type`: String, QueryConvertible {
        case all
        case owner
        case `public`
        case `private`
        case member
    }
}

extension ListRepositoriesForAuthenticatedUser: Defaultable {
    public init() {
        self.init(visibility: nil)
    }
}

extension ListRepositoriesForAuthenticatedUser: Modifiers {
    public func visibility(_ visibility: Visibility) -> Self {
        with { $0.visibility = visibility }
    }

    public func affiliation(_ affiliation: Affiliation) -> Self {
        with { $0.affiliation = affiliation }
    }

    public func type(_ type: `Type`) -> Self {
        with { $0.type = type }
    }
}

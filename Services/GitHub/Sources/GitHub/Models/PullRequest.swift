//
//  PullRequest.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Prelude
import RestClient

public struct PullRequest {
    private let client: GitHubClient

    public let id: Int
    public let title: String

    init(response: PullRequestResponse, client: GitHubClient) {
        self.id = response.id
        self.title = response.title
        self.client = client
    }
}

extension PullRequest {
    public enum SortingKey: String {
        case created
        case updated
        case popularity
        case longRunning = "long-running"
    }

    public enum State: String {
        case opened
        case closed
    }

    public struct Query: KeyPathSettable {
        public var state: State?
        public var base: RefName?
        public var head: RefName?
        public var sorting: Sorting<SortingKey>?

        public init(state: State? = .opened, base: RefName? = nil, head: RefName? = nil, sorting: Sorting<SortingKey>? = nil) {
            self.state = state
            self.base = base
            self.head = head
            self.sorting = sorting
        }
    }
}

extension PullRequest.Query {
    func asRestQuery() -> RestQuery {
        RestQuery
            .set("state", to: state?.rawValue ?? "all")
            .set("head", to: head?.rawValue)
            .set("base", to: base?.rawValue)
            .merging(with: sorting?.asRestQuery())
    }
}

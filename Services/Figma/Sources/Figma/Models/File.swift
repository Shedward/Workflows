//
//  File.swift
//  
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

public struct File {
    private let client: FigmaClient

    public let key: String

    init(client: FigmaClient, key: String) {
        self.client = client
        self.key = key
    }

    public func comments() async throws -> [Comment] {
        let response = try await client.comments(at: key)
        let comments = response.comments.map { commentResponse in
            Comment(response: commentResponse, client: client)
        }
        return comments
    }
}

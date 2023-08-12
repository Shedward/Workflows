//
//  Figma.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

public struct Figma {
    private let client: FigmaClient

    public init(token: String) {
        client = FigmaClient(token: token)
    }

    public func me() async throws -> User {
        let response = try await client.me()
        return User(response: response, client: client)
    }

    public func file(key: String) -> File {
        File(client: client, key: key)
    }
}

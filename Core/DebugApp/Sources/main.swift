// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import RestClient

let request = RestRequest<EmptyBody, PlainTextBody>(
    method: .get,
    path: "/repos/octocat/Spoon-Knife/issues",
    query: RestQuery
        .set("sortBy", to: "createAt"),
    headers: RestHeaders
        .set("Accept", to: "application/vnd.github+json")
        .set("Authorization", to: "...")
)

let endpoint = RestEndpoint(host: URL(string: "https://api.github.com")!)
let client = RestClient(endpoint: endpoint)

let response = try await client.request(request)
print(response)


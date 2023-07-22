// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import GitHub

let github = GitHub(token: "...")
let user = try await github.currentUser()
let repo = try await github.repo(owner: "hhru", name: "ios-apps")
let pullRequests = try await repo.pullRequests().allItems()
print(pullRequests.count)
print(pullRequests)

//let request = RestRequest<EmptyBody, PlainTextBody>(
//    method: .get,
//    path: "/repos/octocat/Spoon-Knife/issues",
//    query: RestQuery
//        .set("sortBy", to: "createAt"),
//    headers: RestHeaders
//        .set("Accept", to: "application/vnd.github+json")
//        .set("Authorization", to: "...")
//)
//
//let endpoint = RestEndpoint(host: URL(string: "https://api.github.com")!)
//let client = RestClient(endpoint: endpoint)
//
//let response = try await client.request(request)
//print(response)



//let usr: String = "..."
//let pwd: String = "..."
//let token = "\(usr):\(pwd)".data(using: .utf8)?.base64EncodedString()


//let jiraRequest = RestRequest<EmptyBody, PlainTextBody>(
//    method: .get,
//    path: "/rest/api/2/user",
//    query: RestQuery
//        .set("username", to: "v.maltsev"),
//    headers: RestHeaders
//        .set("Authorization", to: "Basic \(token!)")
//        .set("Content-Type", to: "application/json")
//)
//
//let endpoint = RestEndpoint(host: URL(string: "https://jira.hh.ru")!)
//let client = RestClient(endpoint: endpoint)
//let response = try await client.request(jiraRequest)
//
//print(response)

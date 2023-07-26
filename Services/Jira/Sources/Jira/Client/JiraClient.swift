//
//  JiraClient.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import RestClient
import Foundation

final class JiraClient {
    let restClient: RestClient

    private init(restClient: RestClient) {
        self.restClient = restClient
    }

    static func jiraServerClient(host: URL, credentials: JiraServerCredentials) throws -> JiraClient {
        let endpoint = RestEndpoint(host: host.appending(path: "/rest/api/2"))
        let jiraToken = try credentials.token()
        let restClient = RestClient(
            endpoint: endpoint,
            requestDecorators: [
                HeadersRequestDecorator(
                    headers: RestHeaders
                        .set("Authorization", to: "Basic \(jiraToken)")
                        .set("Content-Type", to: "application/json")
                )
            ]
        )

        return JiraClient(restClient: restClient)
    }
}
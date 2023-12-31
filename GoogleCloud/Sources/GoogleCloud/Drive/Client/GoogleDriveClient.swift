//
//  GoogleDriveClient.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import Foundation
import RestClient

struct GoogleDriveClient {
    let restClient: RestClient

    init(accessToken: String) {
        let endpoint = RestEndpoint(
            host: URL(string: "https://www.googleapis.com/drive")!
        )
        self.restClient = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: [
                HeadersRequestDecorator(
                    headers: RestHeaders()
                        .set("Accept", to: "application/json")
                        .set("Content-Type", to: "application/json")
                        .set("Authorization", to: "Bearer \(accessToken)")
                )
            ]
        )
    }

    init(authorizer: GoogleAuthorizer) {
        let endpoint = RestEndpoint(
            host: URL(string: "https://www.googleapis.com/drive")!
        )
        self.restClient = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: [
                HeadersRequestDecorator(
                    headers: RestHeaders()
                        .set("Accept", to: "application/json")
                        .set("Content-Type", to: "application/json")
                ),
                AccessTokenAuthorizerRequestDecorator(authorizer: authorizer)
            ]
        )
    }

    init(mock: GoogleDriveMock) {
        self.restClient = mock.restClient
    }
}

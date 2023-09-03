//
//  GoogleDriveClient.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import Foundation
import RestClient

struct GoogleDriveClient {
    let client: RestClient

    init(accessToken: String) {
        let endpoint = RestEndpoint(
            host: URL(string: "https://www.googleapis.com/drive")!
        )
        self.client = RestClient(
            endpoint: endpoint,
            requestDecorators: [
                HeadersRequestDecorator(
                    headers: RestHeaders
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
        self.client = RestClient(
            endpoint: endpoint,
            requestDecorators: [
                HeadersRequestDecorator(
                    headers: RestHeaders
                        .set("Accept", to: "application/json")
                        .set("Content-Type", to: "application/json")
                ),
                AccessTokenAuthorizerRequestDecorator(authorizer: authorizer)
            ]
        )
    }
}

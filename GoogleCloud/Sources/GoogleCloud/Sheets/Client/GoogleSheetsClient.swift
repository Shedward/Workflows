//
//  GoogleSheetsClient.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import RestClient
import Foundation

struct GoogleSheetsClient {
    let client: RestClient

    init(accessToken: String) {
        let endpoint = RestEndpoint(
            host: URL(string: "https://sheets.googleapis.com")!
        )
        self.client = NetworkRestClient(
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
            host: URL(string: "https://sheets.googleapis.com")!
        )
        self.client = NetworkRestClient(
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

    init(mock: GoogleSheetsMock) {
        self.client = mock.restClient
    }
}

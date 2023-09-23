//
//  FigmaClient.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import RestClient
import Foundation

struct FigmaClient {
    let restClient: RestClient

    init(token: String) {
        let endpoint = RestEndpoint(host: URL(string: "https://api.figma.com")!)

        restClient = NetworkRestClient(
            endpoint: endpoint,
            requestDecorators: [
                HeadersRequestDecorator(
                    headers: RestHeaders()
                        .set("X-FIGMA-TOKEN", to: token)
                )
            ]
        )
    }
}

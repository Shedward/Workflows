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
                HeadersRequestDecorator(headers: .set("Authorization", to: "Bearer \(accessToken)"))
            ]
        )
    }
}

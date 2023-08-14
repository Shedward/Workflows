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

    init(key: String) {
        let endpoint = RestEndpoint(
            host: URL(string: "https://sheets.googleapis.com")!
        )
        self.client = RestClient(
            endpoint: endpoint,
            requestDecorators: [
                QueryRequestDecorator(query: .set("key", to: key))
            ]
        )
    }
}

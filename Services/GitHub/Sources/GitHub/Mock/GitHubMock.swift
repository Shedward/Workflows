//
//  GitHubMock.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import RestClient

public struct GitHubMock {
    let restClient: MockRestClient

    public init() {
        self.restClient = MockRestClient()
    }
}

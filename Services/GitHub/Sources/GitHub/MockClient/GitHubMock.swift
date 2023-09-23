//
//  GitHubMock.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

import RestClient

public struct GitHubMock {
    let mockRestClient: MockRestClient

    public init() {
        self.mockRestClient = MockRestClient()
    }
}

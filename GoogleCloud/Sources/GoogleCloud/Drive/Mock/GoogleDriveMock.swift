//
//  GoogleDriveMock.swift
//
//
//  Created by v.maltsev on 24.09.2023.
//

import RestClient

public struct GoogleDriveMock {
    let restClient: MockRestClient

    public init() {
        self.restClient = MockRestClient()
    }
}

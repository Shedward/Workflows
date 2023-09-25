//
//  GoogleSheetsMock.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

import RestClient

public struct GoogleSheetsMock {
    let restClient: MockRestClient

    public init() {
        self.restClient = MockRestClient()
    }
}

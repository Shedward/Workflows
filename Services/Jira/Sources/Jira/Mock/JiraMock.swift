//
//  JiraMock.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import RestClient

public struct JiraMock {
    let restClient: MockRestClient
    
    public init() {
        self.restClient = MockRestClient("Jira")
    }
}

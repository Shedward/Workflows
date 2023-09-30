//
//  JiraMock.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import RestClient

struct JiraMock {
    let restClient: MockRestClient
    
    init() {
        self.restClient = MockRestClient("Jira")
    }
}

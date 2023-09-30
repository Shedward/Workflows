//
//  FigmaMock.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

import RestClient

struct FigmaMock {
    let restClient: MockRestClient

    init() {
        self.restClient = MockRestClient("Figma")
    }
}

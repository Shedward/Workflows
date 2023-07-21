//
//  RestConfiguration.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

import Foundation

public struct RestEndpoint {
    public let host: URL

    public init(host: URL) {
        self.host = host
    }
}

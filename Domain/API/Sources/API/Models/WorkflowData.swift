//
//  WorkflowData.swift
//  API
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Rest

public struct WorkflowData: JSONBody {
    public let data: [String: String]

    public init(data: [String : String]) {
        self.data = data
    }
}

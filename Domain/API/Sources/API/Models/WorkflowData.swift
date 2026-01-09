//
//  WorkflowData.swift
//  API
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Rest

public struct WorkflowData: JSONBody {
    public let data: [String: RawJson]

    public init(data: [String : RawJson]) {
        self.data = data
    }
}

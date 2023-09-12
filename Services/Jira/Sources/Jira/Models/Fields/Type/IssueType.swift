//
//  IssueType.swift
//
//
//  Created by v.maltsev on 12.09.2023.
//

import Foundation

public struct IssueType: Decodable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let iconUrl: String?
    public let subtask: Bool
}

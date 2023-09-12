//
//  IssueStatus.swift
//
//
//  Created by v.maltsev on 12.09.2023.
//

public struct IssueStatus: Decodable, Sendable {
    public let id: String
    public let name: String
    public let iconUrl: String?
    public let description: String?
}

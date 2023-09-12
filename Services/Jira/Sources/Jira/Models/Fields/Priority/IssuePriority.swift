//
//  IssuePriority.swift
//
//
//  Created by v.maltsev on 12.09.2023.
//

import Foundation

public struct IssuePriority: Decodable, Sendable {
    public let id: String
    public let name: String
    public let iconUrl: String?
}

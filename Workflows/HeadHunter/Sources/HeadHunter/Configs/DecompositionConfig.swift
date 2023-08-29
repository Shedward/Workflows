//
//  DecompositionConfig.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import Foundation

public struct DecompositionConfig: Decodable {
    public var templateFileId: String
    public var decompositionsFolderId: String
    public var titleCell: String
    public var projectKeyCell: String
    public var projectKey: String
}

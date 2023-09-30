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
    
    init(templateFileId: String, decompositionsFolderId: String, titleCell: String, projectKeyCell: String, projectKey: String) {
        self.templateFileId = templateFileId
        self.decompositionsFolderId = decompositionsFolderId
        self.titleCell = titleCell
        self.projectKeyCell = projectKeyCell
        self.projectKey = projectKey
    }
}

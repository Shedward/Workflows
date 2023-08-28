//
//  CreateFile.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

public struct CreateFile {
    public var name: String
    public var parents: [String]
    public var mimeType: String?

    public init(name: String, parents: [String] = [], mimeType: String? = nil) {
        self.name = name
        self.parents = parents
        self.mimeType = mimeType
    }
}

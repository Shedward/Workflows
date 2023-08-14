//
//  CreateFileRequest.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import RestClient

public struct CreateFileRequest: JSONEncodableBody {
    let name: String
    let mimeType: String
    let parents: [String]

    init(createFile: CreateFile) {
        self.name = createFile.name
        self.mimeType = createFile.mimeType
        self.parents = createFile.parents
    }
}

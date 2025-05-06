//
//  FileResponse.swift
//
//
//  Created by v.maltsev on 14.08.2023.
//

import RestClient

struct FileResponse: JSONDecodableBody {
    let id: String
    let name: String
    let webViewLink: String?
}

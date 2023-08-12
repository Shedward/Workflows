//
//  CommentResponse.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import Foundation
import RestClient

struct CommentResponse: JSONDecodableBody {
    let id: String
    let parentId: String?
    let message: String
    let createdAt: Date
    let resolvedAt: Date?

    static func decoder() -> JSONDecoder {
        Decoders.decoder
    }
}

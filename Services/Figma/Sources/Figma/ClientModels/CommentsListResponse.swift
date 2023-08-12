//
//  CommentsListResponse.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import Foundation
import RestClient

struct CommentsListResponse: JSONDecodableBody {
    let comments: [CommentResponse]

    static func decoder() -> JSONDecoder {
        Decoders.decoder
    }
}

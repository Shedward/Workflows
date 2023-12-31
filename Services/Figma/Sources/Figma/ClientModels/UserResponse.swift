//
//  UserResponse.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import Foundation
import RestClient

struct UserResponse: JSONDecodableBody {
    let id: String
    let email: String
    let handle: String

    static func decoder() -> JSONDecoder {
        Decoders.decoder
    }
}

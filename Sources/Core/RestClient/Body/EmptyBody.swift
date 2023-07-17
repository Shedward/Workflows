//
//  EmptyBody.swift
//  Created by Vladislav Maltsev on 17.07.2023.
//

import Foundation

struct EmptyBody: RestBodyCodable {
    static func fromData(_ data: Data) -> EmptyBody {
        EmptyBody()
    }

    func data() -> Data? {
        nil
    }
}

extension EmptyBody: DefaultInitable { }

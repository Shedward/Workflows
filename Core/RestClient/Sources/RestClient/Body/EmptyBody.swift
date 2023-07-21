//
//  EmptyBody.swift
//  Created by Vladislav Maltsev on 17.07.2023.
//

import Foundation
import Prelude

public struct EmptyBody: RestBodyCodable, DefaultInitable {
    public init() {
    }

    public static func fromData(_ data: Data) -> EmptyBody {
        EmptyBody()
    }

    public func data() -> Data? {
        nil
    }
}

//
//  RestBodyCodable.swift
//  Created by Vladislav Maltsev on 18.07.2023.
//

import Foundation

protocol RestBodyEncodable {
    func data() throws -> Data?
}

protocol RestBodyDecodable {
    static func fromData(_ data: Data) throws -> Self
}

typealias RestBodyCodable = RestBodyEncodable & RestBodyDecodable

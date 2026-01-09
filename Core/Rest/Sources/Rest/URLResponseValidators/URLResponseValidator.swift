//
//  URLResponseValidator.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Foundation

public protocol URLResponseValidator: Sendable {
    func validate(_ response: URLResponse) throws
}

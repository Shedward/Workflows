//
//  DescriptiveError.swift
//  Core
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Foundation

public protocol DescriptiveError: Error, LocalizedError {
    var userDescription: String { get }
}

public extension DescriptiveError {
    var userDescription: String {
        "\(self)"
    }
}

//
//  DescriptiveError.swift
//  Created by Vladislav Maltsev on 16.07.2023.
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

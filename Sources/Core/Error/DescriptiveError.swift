//
//  DescriptiveError.swift
//  Created by Vladislav Maltsev on 16.07.2023.
//

protocol DescriptiveError: Error {
    var userDescription: String { get }
}

extension DescriptiveError {
    var userDescription: String {
        "\(self)"
    }
}

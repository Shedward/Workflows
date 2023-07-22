//
//  ResponseValidator.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Foundation

public protocol ResponseValidator {
    func validate(_ response: URLResponse) throws
}

//
//  ExecutableError.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 28.07.2023.
//

import Foundation

public enum ExecutableError: Error {
    case failedToRun(Error)
    case unsuccessfullTermination(ExecutableTermination)
}

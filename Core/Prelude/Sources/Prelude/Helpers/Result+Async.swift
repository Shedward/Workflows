//
//  Result+Async.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

import Foundation

extension Result where Failure == Error {
    public static func `async`(_ body: () async throws -> Success) async throws -> Self {
        do {
            return .success(try await body())
        } catch {
            return .failure(error)
        }
    }
}

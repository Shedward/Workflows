//
//  Repository+Branches.swift
//  
//
//  Created by Vlad Maltsev on 23.01.2024.
//

import Prelude

extension Repository {
    
    public func checkout(to ref: Ref) async throws {
        try await git
            .run("checkout", ref.rawValue)
            .finished()
    }
    
    public func createAndCheckout(to ref: Ref) async throws {
        try await git
            .run("checkout", "-b", ref.rawValue)
            .finished()
    }
    
    public func currentRef() async throws -> Ref {
        let output = try await git.runForOutput("rev-parse", "--abbrev-ref", "HEAD")
        let branchName = output.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !branchName.isEmpty else {
            throw Failure("Unexpected empty branch name")
        }

        return Ref(rawValue: branchName)
    }
    
    public func refExists(_ ref: Ref) async throws -> Bool {
        try await git
            .run("rev-parse", "--verify", ref.rawValue)
            .mapStatusCode { $0 == 0 }
    }
}

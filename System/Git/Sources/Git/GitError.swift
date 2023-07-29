//
//  GitError.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

enum GitError: Error {
    case noGitRepositoryAtPath(String)
}

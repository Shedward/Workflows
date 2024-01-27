//
//  CachedRepository.swift
//
//
//  Created by Vlad Maltsev on 13.12.2023.
//

import Prelude
import FileSystem
import Executable

public enum CachedRepositoryError: Error {
    case folderAlreadyExists(String)
}

public struct CachedRepository {
    private let git: Git
    private let repoUrl: String
    private let cacheDirectory: FileItem
    
    public init(git: Git = Git(), repoUrl: String, cacheDirectory: FileItem) {
        self.git = git
        self.repoUrl = repoUrl
        self.cacheDirectory = cacheDirectory
    }
    
    public func clone(to destination: FileItem, logs: ExecutableLogs? = nil) async throws -> Repository {
        if destination.isExists {
            throw Failure("Can't clone repository to \(destination). Directory already exists.")
        }
        
        if cacheDirectory.isExists, try await git.exists(in: cacheDirectory)  {
            try await copyCache(to: destination)
        } else {
            try await Failure.wrap("Cloning original repository \(repoUrl) to \(destination)") {
                try cacheDirectory.createDirectory()
                _ = try await git.clone(repoUrl, to: cacheDirectory)
            }
            try await copyCache(to: destination)
        }
        
        return try await git.repository(at: destination)
    }
    
    private func copyCache(to destination: FileItem) async throws {
        try await Failure.wrap("Fetch updates for \(repoUrl) in \(cacheDirectory)") {
            let repository = try await git.repository(at: cacheDirectory)
            
            try await repository.fetch()
            try await repository.pull()
        }
        
        try Failure.wrap("Copying cache repository from \(cacheDirectory) to \(destination)") {
            let destinationParrent = try destination.parrent()
            if !destinationParrent.isExists {
                try destinationParrent.createDirectory()
            }
            try cacheDirectory.copy(to: destination)
        }
    }
}

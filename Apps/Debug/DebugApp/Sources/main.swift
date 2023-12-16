// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LocalStorage
import SecureStorage
import RestClient
import GitHub
import Jira
import Figma
import Executable
import Prelude
import os
import Git
import GoogleCloud
import HeadHunter
import FileSystem

let debugCredentials = DebugCredentials()

extension LoggerScope {
    static let demoApp = LoggerScope(name: "Demo App")
}

Logger.enabledScopes = [.network, .demoApp, .global, .executables]

let logger = Logger(scope: .demoApp)

func testCachedRepository() async throws {
    let fileSystem = FileManagerFileSystem()
    let cachedRepoDirectory = fileSystem.homeDirectory().appending("workflows/shared/repositories/ios-apps")
    let copyRepoDirectory = fileSystem.homeDirectory().appending("workflows/workflow-0/ios-apps")
    
    let cachedRepository = CachedRepository(
        repoUrl: "git@github.com:hhru/ios-apps.git",
        cacheDirectory: cachedRepoDirectory
    )
    
    let repo = try await cachedRepository.clone(to: copyRepoDirectory)
    let currentBranch = try await repo.currentBranch()
    print(currentBranch)
}

try await testCachedRepository()

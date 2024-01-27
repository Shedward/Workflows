//
//  CachedRepository+RepoDetails.swift
//
//
//  Created by Vlad Maltsev on 20.01.2024.
//

import Git
import FileSystem
import Workflow

extension CachedRepository {
    init(git: Git, repo: RepoDetails, workflowStorage: WorkflowStorage) {
        self.init(
            git: git,
            repoUrl: repo.ssh,
            cacheDirectory: workflowStorage.sharedCacheRepo(repo)
        )
    }
}

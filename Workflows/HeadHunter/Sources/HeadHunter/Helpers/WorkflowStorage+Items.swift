//
//  WorkflowStorage+Items.swift
//
//
//  Created by Vlad Maltsev on 20.01.2024.
//

import Workflow
import FileSystem

extension WorkflowStorage {
    func sharedCacheRepo(_ repoName: Repo) -> FileItem {
        sharedItem
            .appending("cached_repos")
            .appending(repoName.rawValue)
    }
    
    func sharedCacheRepo(_ repoDetails: RepoDetails) -> FileItem {
        sharedCacheRepo(repoDetails.name)
    }
    
    func repo(_ repoName: Repo) -> FileItem {
        rootItem.appending(repoName.rawValue)
    }
    
    func repo(_ repoDetails: RepoDetails) -> FileItem {
        repo(repoDetails.name)
    }
}

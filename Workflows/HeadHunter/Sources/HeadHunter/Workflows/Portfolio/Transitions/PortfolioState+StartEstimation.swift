//
//  PortfolioState+StartEstimation.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import Workflow
import Prelude
import Git
import Executable
import FileSystem

extension PortfolioState {
    struct StartEstimation: Transition {
        
        let id = "Portfolio.StartEstimation"
        let name = "Декомпозировать"
        
        let todo: PortfolioState.ToDo
        
        var steps: TransitionSteps<PortfolioState> {
            .init { ctx in
                let iosRepoPath = ctx.promises.promise(id: "IosRepoPath", for: Path.self)
                TransitionStep(id: "1.CloneRepository", name: "Клонирование репозитория") { progress in
                    let gitConfig = try ctx.dependencies.configs.git()
                    let iosAppsRepo = try gitConfig.repo(.iosApps)

                    let repository = CachedRepository(
                        git: ctx.dependencies.git,
                        repo: iosAppsRepo,
                        workflowStorage: ctx.workflow.storage
                    )
                    
                    let repoItem = ctx.workflow.storage.repo(iosAppsRepo)
                    _ = try await repository.clone(to: repoItem)
                    await iosRepoPath.fulfill(repoItem.path)
                }
                
                TransitionStep(id: "2.CheckoutBranch", name: "Получение ветки") { progressGroup in
                    let repoItem = ctx.workflow.storage.repo(.iosApps)
                    let portfolioRef = Ref(rawValue: todo.taskId)
                    let repo = try await ctx.dependencies.git.repository(at: repoItem)
                    
                    if try await repo.remoteRefExists(portfolioRef) {
                        try await repo.fetch()
                        try await repo.checkout(to: portfolioRef)
                        progressGroup.state = .finished("Портфельная ветка получена с remote")
                    } else if try await repo.refExists(portfolioRef) {
                        try await repo.checkout(to: portfolioRef)
                        progressGroup.state = .finished("Портфельная ветка уже существует")
                    } else {
                        try await repo.createAndCheckout(to: portfolioRef)
                        progressGroup.state = .finished("Портфельная ветка создана")
                    }
                }
                TransitionStep(id: "3.ToolsUpsh", name: "./Tools/up.sh") { _ in
                    let upshPath = ctx.workflow.storage.repo(.iosApps).appending("Tools/up.sh")
                    try await ProcessExecutable(path: upshPath.path.string)
                        .run("--open")
                        .finished()
                }
            }
        }
    }
}

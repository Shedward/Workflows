//
//  CreateDecompositionTableAction.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import Foundation
import GoogleCloud

public struct CreateDecompositionTableAction: WorkflowAction {

    public typealias Dependencies =
        GoogleDriveDependency
        & GoogleSheetsDependency

    let deps: Dependencies
    let config: DecompositionConfig

    let portfolioKey: String

    public var title: String {
        "Создать таблицу для декомпозиции"
    }

    public init(deps: Dependencies, config: DecompositionConfig, portfolioKey: String) {
        self.deps = deps
        self.config = config
        self.portfolioKey = portfolioKey
    }

    public func perform() async throws {
        let decompositionCreateFile = CreateFile(name: portfolioKey, parents: [config.decompositionsFolderId])
        let decompositionFile = try await deps.googleDrive.copy(
            fileId: config.templateFileId,
            to: decompositionCreateFile
        )
    }
}

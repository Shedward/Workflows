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
        let decompositionTemplateFile = deps.googleDrive.file(id: config.templateFileId)
        let decompositionCreateFile = CreateFile(name: portfolioKey, parents: [config.decompositionsFolderId])
        let decompositionFile = try await decompositionTemplateFile.copy(to: decompositionCreateFile)

        let spreadsheet = deps.googleSheets.spreadsheet(id: decompositionFile.id)
        try await spreadsheet.cells(config.titleCell).update(to: .string(portfolioKey))
        try await spreadsheet.cells(config.projectKeyCell).update(to: .string(config.projectKey))

        // TODO: Open for sharing
        // TODO: output decomposition url
    }
}

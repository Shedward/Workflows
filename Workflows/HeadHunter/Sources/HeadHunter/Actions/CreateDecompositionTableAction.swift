//
//  CreateDecompositionTableAction.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import Foundation
import Prelude
import Jira
import GoogleCloud

public struct CreateDecompositionTableAction {

    public typealias Dependencies =
        GoogleDriveDependency
        & GoogleSheetsDependency
        & JiraDependency

    let deps: Dependencies
    let config: DecompositionConfig

    public var title: String {
        "Создать таблицу для декомпозиции"
    }

    public init(deps: Dependencies, config: DecompositionConfig) {
        self.deps = deps
        self.config = config
    }
}

extension CreateDecompositionTableAction: WorkflowAction {

    public struct Input {
        public let portfolioKey: String

        public init(portfolioKey: String) {
            self.portfolioKey = portfolioKey
        }
    }

    public struct Output {
        public let decompositionSpreadsheet: Spreadsheet
        public let decompositonUrl: String
    }

    public func perform(_ input: Input) async throws -> Output {
        let decompositionTemplateFile = deps.googleDrive.file(id: config.templateFileId)

        let issue = try await deps.jira.issue(key: input.portfolioKey, fields: SummaryFields.self)

        let fileName = "\(issue.key): \(issue.fileds.summary)"
        let decompositionCreateFile = CreateFile(name: fileName, parents: [config.decompositionsFolderId])
        let decompositionFile = try await decompositionTemplateFile.copy(to: decompositionCreateFile).file()

        let spreadsheet = deps.googleSheets.spreadsheet(id: decompositionFile.id)
        try await spreadsheet.cells(config.titleCell).update(to: .string(input.portfolioKey))
        try await spreadsheet.cells(config.projectKeyCell).update(to: .string(config.projectKey))

        try await decompositionFile.permissions().create(.init(group: .anyone, role: .reader))

        let updatedFileDetails = try await decompositionFile.details(fields: [.webViewLink])
        guard let decompositionUrl = updatedFileDetails.webViewLink else {
            throw Failure("Decomposition file was created but failed to get sharing URL")
        }

        return Output(
            decompositionSpreadsheet: spreadsheet,
            decompositonUrl: decompositionUrl
        )
    }
}

private struct SummaryFields: IssueFields {
    let summary: String

    static var fieldKeys: [IssueFieldKey] {
        ["summary"]
    }
}

//
//  WaitForFileContent.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import Foundation
import WorkflowEngine

@DataBindable
struct WaitForFileContent: Wait {
    @Input var messageFile: URL

    func resume() async throws -> Waiting.Time? {
        let fileContent = try String(contentsOf: messageFile, encoding: .utf8)

        if fileContent.isEmpty {
            return .after(seconds: 1)
        } else {
            return nil
        }
    }
}


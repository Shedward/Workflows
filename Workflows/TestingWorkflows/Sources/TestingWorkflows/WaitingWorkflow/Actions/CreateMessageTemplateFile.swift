//
//  CreateMessageTemplateFile.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import Foundation
import WorkflowEngine

@DataBindable
struct CreateMessageTemplateFile: Action {
    @Output var messageFile: URL

    func run() async throws {
        let templateFileURL = URL(filePath: "/tmp/MessageTemplate.md")
        try "".write(to: templateFileURL, atomically: false, encoding: .utf8)

        messageFile = templateFileURL
    }
}

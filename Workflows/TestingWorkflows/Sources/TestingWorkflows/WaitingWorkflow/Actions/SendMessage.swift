//
//  SendMessage.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import Foundation
import WorkflowEngine

@DataBindable
struct SendMessage: Action {
    @Input var messageFile: URL

    func run() async throws {
        print("Message \(messageFile) sent")
    }
}

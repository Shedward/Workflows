//
//  Config.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import Rest
import Foundation

struct Config {
    let workflowsService: WorkflowsService
}

extension Config {
    static var debug: Config {
        let endpoint = NetworkRestClient.Endpoint(host: URL(string: "https://127.0.0.1:8443")!)

        let workflowService = WorkflowsService(endpoint: endpoint)

        return Config(
            workflowsService: workflowService
        )
    }
}

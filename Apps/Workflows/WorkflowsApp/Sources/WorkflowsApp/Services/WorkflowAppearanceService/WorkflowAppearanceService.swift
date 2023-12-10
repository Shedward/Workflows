//
//  WorkflowAppearanceService.swift
//
//
//  Created by Vlad Maltsev on 10.12.2023.
//

import SwiftUI
import Workflow
import UI

struct WorkflowTypeAppearance {
    let icon: Image
    let name: String
    let tintColor: ColorToken
    
    static let `default` = WorkflowTypeAppearance(
        icon: Image(systemName: "flowchart"),
        name: "Workflow",
        tintColor: \.content.primary
    )
}

final class WorkflowAppearanceService {
    private let appearances: [WorkflowType: WorkflowTypeAppearance]
    
    init(appearances: [WorkflowType : WorkflowTypeAppearance]) {
        self.appearances = appearances
    }
    
    func appearance(for type: WorkflowType) -> WorkflowTypeAppearance {
        appearances[type] ?? .default
    }
}

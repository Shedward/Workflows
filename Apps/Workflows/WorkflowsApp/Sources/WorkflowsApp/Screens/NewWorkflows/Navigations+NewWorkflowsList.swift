//
//  Navigations+NewWorkflowsList.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

extension Navigation {
    struct NewWorkflowsList: Hashable {
    }
    
    func showNewWorkflows() {
        path.append(NewWorkflowsList())
    }
}

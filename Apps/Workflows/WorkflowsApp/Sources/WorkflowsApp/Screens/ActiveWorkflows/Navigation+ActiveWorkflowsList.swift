//
//  Navigations+ActiveWorkflowsList.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI

extension Navigation {
    struct ActiveWorkflowsList: Hashable {
    }
    
    func showActiveWorkflows() {
        path.append(ActiveWorkflowsList())
    }
}

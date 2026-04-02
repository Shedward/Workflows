//
//  TransitionLogger.swift
//  workflow-server
//
//  Created by Мальцев Владислав on 31.03.2026.
//

import WorkflowEngine

struct TransitionLogger: WorkflowTransitionListener {
    func workflowDidStart(instance: WorkflowInstance) {
        debugPrint("🐠 didStart", instance)
    }

    func workflowWillTransition(instance: WorkflowInstance, transition: TransitionID) {
        debugPrint("🐠 willTransition", instance, transition)
    }

    func workflowDidTransition(instance: WorkflowInstance, transition: TransitionID) {
        debugPrint("🐠 didTransition", instance, transition)
    }

    func workflowDidFinish(instance: WorkflowInstance) {
        debugPrint("🐠 didFinish", instance)
    }
}

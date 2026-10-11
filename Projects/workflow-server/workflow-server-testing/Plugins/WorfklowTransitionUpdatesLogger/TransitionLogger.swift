//
//  TransitionLogger.swift
//  workflow-server
//
//  Created by Мальцев Владислав on 31.03.2026.
//

import Foundation
import WorkflowEngine

struct TransitionLogger: WorkflowTransitionListener {
    func workflowDidStart(instance: WorkflowInstance) {
        debugPrint("🐠 didStart", instance)
    }

    func workflowWillTransition(instance: WorkflowInstance, transition: TransitionID, traceId: UUID) {
        debugPrint("🐠 willTransition", instance, transition, traceId)
    }

    func workflowDidTransition(instance: WorkflowInstance, transition: TransitionID, traceId: UUID) {
        debugPrint("🐠 didTransition", instance, transition, traceId)
    }

    func workflowDidFinish(instance: WorkflowInstance) {
        debugPrint("🐠 didFinish", instance)
    }
}

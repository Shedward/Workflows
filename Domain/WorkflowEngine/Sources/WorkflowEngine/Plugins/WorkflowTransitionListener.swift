//
//  WorkflowTransitionListener.swift
//  WorkflowEngine
//
//  Created by Мальцев Владислав on 31.03.2026.
//

import Core
import Foundation

public protocol WorkflowTransitionListener: PluginObject {
    func workflowDidStart(instance: WorkflowInstance)
    func workflowWillTransition(instance: WorkflowInstance, transition: TransitionID, traceId: UUID)
    func workflowDidTransition(instance: WorkflowInstance, transition: TransitionID, traceId: UUID)
    func workflowDidFinish(instance: WorkflowInstance)
}

public extension WorkflowTransitionListener {
    func workflowDidStart(instance: WorkflowInstance) {
    }

    func workflowWillTransition(instance: WorkflowInstance, transition: TransitionID, traceId: UUID) {
    }

    func workflowDidTransition(instance: WorkflowInstance, transition: TransitionID, traceId: UUID) {
    }

    func workflowDidFinish(instance: WorkflowInstance) {
    }
}

//
//  TransitionTimeProfiler.swift
//  workflow-server
//
//  Created by Мальцев Владислав on 31.03.2026.
//

import Foundation
import WorkflowEngine

final class TransitionTimeProfiler: WorkflowTransitionListener, @unchecked Sendable {
    private var lock = os_unfair_lock_s()

    private(set) var measurements: [TransitionID: [TimeInterval]] = [:]
    private(set) var ongointTransitions: [UUID: TimeInterval] = [:]

    init() {
    }

    func workflowWillTransition(instance: WorkflowInstance, transition: TransitionID, traceId: UUID) {
        let startTime = Date.timeIntervalSinceReferenceDate
        locked {
            ongointTransitions[traceId] = startTime
        }
    }

    func workflowDidTransition(instance: WorkflowInstance, transition: TransitionID, traceId: UUID) {
        let endTime = Date.timeIntervalSinceReferenceDate
        locked {
            if let startTime = ongointTransitions.removeValue(forKey: traceId) {
                measurements[transition, default: []].append(endTime - startTime)
            }
        }
    }

    func workflowDidFinish(instance: WorkflowInstance) {
        locked {
            let collectedMeasurements = measurements
                .filter { key, _ in
                    key.workflow == instance.workflowId
                }
            debugPrint("🐠🐠", collectedMeasurements)
        }
    }

    private func locked(_ action: () -> Void) {
        os_unfair_lock_lock(&lock)
        action()
        os_unfair_lock_unlock(&lock)
    }
}

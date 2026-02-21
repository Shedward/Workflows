//
//  WorkflowTypesController.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import API
import Rest
import Hummingbird
import WorkflowEngine

struct WorkflowsController: Controller {
    let workflows: Workflows

    var endpoints: RouteCollection<AppRequestContext> {
        RouteCollection()
            .on(GetWorkflows.self, use: getWorkflowTypes)
    }

    private func getWorkflowTypes(request: Request, body: EmptyBody, context: Context) async throws -> ListBody<API.Workflow> {
        let allWorkflows = await workflows.workflows()
        let instances = allWorkflows.map { workflow in
            API.Workflow(
                id: workflow.id,
                stateId: workflow.states,
                transitions: workflow.anyTransitions.map { transition in
                    API.Transition(
                        processId: transition.id.processId,
                        fromState: transition.id.from,
                        toState: transition.id.to
                    )
                }
            )
        }
        return ListBody(items: instances)
    }
}

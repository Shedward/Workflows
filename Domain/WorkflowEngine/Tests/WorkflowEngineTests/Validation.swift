import Testing
import WorkflowEngine

/// Validates `workflow` the way the registry does: subflows first, sharing one graph builder.
func validate(
    _ workflow: any Workflow,
    after subflows: [any Workflow] = [],
    dependencies: DependenciesContainer = DependenciesContainer()
) -> WorkflowValidationResult {
    var builder = WorkflowGraphBuilder()
    for subflow in subflows {
        _ = WorkflowValidator.validate(workflow: subflow, dependencies: dependencies, graphBuilder: &builder)
    }
    return WorkflowValidator.validate(workflow: workflow, dependencies: dependencies, graphBuilder: &builder)
}

/// Compares the messages regardless of order: the validator does not promise one.
func expect(
    _ result: WorkflowValidationResult,
    errors: [String] = [],
    warnings: [String] = [],
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(result.errors.map(\.description).sorted() == errors.sorted(), sourceLocation: sourceLocation)
    #expect(result.warnings.map(\.description).sorted() == warnings.sorted(), sourceLocation: sourceLocation)
    #expect(result.isValid == errors.isEmpty, sourceLocation: sourceLocation)
}

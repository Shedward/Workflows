import Testing
import WorkflowEngine

@Suite("Validator: structure")
struct StructureValidationTests {
    @Test func linearWorkflowIsValid() {
        expect(validate(LinearWorkflow()))
    }

    @Test func finishThatCannotBeReached() {
        expect(
            validate(UnreachableFinishWorkflow()),
            errors: [
                "No path from start to finish exists",
                "State 'a' has no outgoing transitions and is not a finish state"
            ]
        )
    }

    @Test func declaredStateThatIsNeverUsed() {
        expect(
            validate(UnreachableStateWorkflow()),
            warnings: ["State 'phantom' is declared but never used in any transition"]
        )
    }

    @Test func automaticCycleWithoutManualExit() {
        expect(
            validate(AutomaticCycleWorkflow()),
            errors: [
                "Cycle involving states loopA → loopB has only automatic transitions and no manual exit",
                "No path from start to finish exists"
            ],
            warnings: ["Cycle detected involving states: loopA → loopB"]
        )
    }

    @Test func cycleWithManualExitIsOnlyAWarning() {
        expect(
            validate(CycleWithManualExitWorkflow()),
            warnings: ["Cycle detected involving states: ping → pong"]
        )
    }

    @Test func twoAutomaticTransitionsFromOneState() {
        expect(
            validate(AmbiguousAutomaticWorkflow()),
            warnings: ["State '_start' has 2 automatic transitions (expected at most 1)"]
        )
    }
}

@Suite("Validator: data flow")
struct DataFlowValidationTests {
    @Test func inputNobodyProduces() {
        expect(
            validate(UndeclaredInputWorkflow()),
            errors: [
                "Input 'ghost' required by 'ConsumeGhost' is not produced by any transition and not declared as workflow input"
            ]
        )
    }

    @Test func declaredOutputNobodyProduces() {
        expect(
            validate(UndeclaredOutputWorkflow()),
            errors: ["Declared workflow output 'result' is not produced on all paths to finish"]
        )
    }

    @Test func inputProducedOnOnlyOneBranch() {
        expect(
            validate(ConditionalInputWorkflow()),
            errors: [
                "Input 'data' required by 'ConsumeString' at state 'merge' is only available on some branches",
                "Input 'data' required by 'ConsumeString' is not produced by any transition and not declared as workflow input"
            ]
        )
    }

    @Test func inputProducedOnEveryBranchIsValid() {
        expect(validate(BranchesAgreeWorkflow()))
    }

    @Test func branchesProduceDifferentTypesForOneKey() {
        expect(
            validate(TypeMismatchWorkflow()),
            errors: ["Data key 'data' has conflicting types Int, String at state 'merge'"]
        )
    }

    @Test func consumerExpectsAnotherTypeThanProduced() {
        expect(
            validate(WrongInputTypeWorkflow()),
            errors: ["Data key 'data' has conflicting types Int, String at state 'produced'"]
        )
    }

    @Test func declaredInputNobodyConsumes() {
        expect(
            validate(UnusedInputWorkflow()),
            warnings: ["Declared workflow input 'unused' is never consumed by any transition"]
        )
    }

    @Test func declaredInputAndOutputAreSatisfied() {
        expect(validate(DeclaredIOWorkflow()))
    }
}

@Suite("Validator: dependencies")
struct DependencyValidationTests {
    @Test func transitionNeedsUnregisteredDependency() {
        expect(
            validate(MissingDependencyWorkflow()),
            errors: ["Dependency 'service' (UnregisteredService) required by 'NeedsMissingDependency' is not registered"]
        )
    }

    @Test func registeredDependencyIsValid() {
        let dependencies = DependenciesContainer(["service": StubService()])
        expect(validate(MissingDependencyWorkflow(), dependencies: dependencies))
    }

    @Test func startProviderNeedsUnregisteredDependency() {
        expect(
            validate(NeedyProviderWorkflow()),
            errors: ["Dependency 'service' (UnregisteredService) required by provider 'NeedyProvider' is not registered"]
        )
    }
}

@Suite("Validator: subflows")
struct SubflowValidationTests {
    @Test func subflowInputParentDoesNotProvide() {
        expect(
            validate(UnsatisfiedSubflowInputWorkflow(), after: [NeedySubflow()]),
            errors: [
                "Input 'requiredData' required by 'NeedySubflow' is not produced by any transition and not declared as workflow input",
                "Subflow 'NeedySubflow' requires input 'requiredData' which is not available at state 'beforeSubflow'"
            ]
        )
    }

    @Test func subflowInputParentProvidesIsValid() {
        expect(validate(SatisfiedSubflowInputWorkflow(), after: [NeedySubflow()]))
    }
}

@Suite("Graph")
struct WorkflowGraphTests {
    @Test func statesIncludeImplicitStartAndFinish() {
        var builder = WorkflowGraphBuilder()
        let graph = builder.build(from: LinearWorkflow())

        #expect(graph.workflowId == "LinearWorkflow")
        #expect(graph.states.map(\.id) == ["_start", "middle", "_finish"])
        #expect(graph.states.filter(\.isStart).map(\.id) == ["_start"])
        #expect(graph.states.filter(\.isFinish).map(\.id) == ["_finish"])
    }

    @Test func transitionsCarryMetadataAndSubflowId() {
        var builder = WorkflowGraphBuilder()
        let graph = builder.build(from: SatisfiedSubflowInputWorkflow())

        #expect(graph.transitions.map(\.processId) == ["ProduceRequiredData", "NeedySubflow", "Finalize"])
        #expect(graph.transitions.map(\.subflowId) == [nil, "NeedySubflow", nil])
        #expect(graph.transitions[0].metadata.outputKeys == ["requiredData"])
        #expect(graph.transitions[1].metadata.inputKeys == ["requiredData"])
        #expect(graph.transitions.allSatisfy { $0.trigger == .manual })
    }

    @Test func declaredInputsAndProducedOutputs() {
        var builder = WorkflowGraphBuilder()
        let graph = builder.build(from: DeclaredIOWorkflow())

        #expect(graph.requiredInputs.map(\.key) == ["data"])
        #expect(graph.requiredInputs.map(\.valueType) == ["String"])
        #expect(graph.producedOutputs.map(\.key) == ["result"])
    }

    @Test func undeclaredDataIsNotPartOfTheContract() {
        var builder = WorkflowGraphBuilder()
        let graph = builder.build(from: BranchesAgreeWorkflow())

        #expect(graph.requiredInputs.isEmpty)
        #expect(graph.producedOutputs.isEmpty)
    }
}

@Suite("Registry")
struct WorkflowRegistryTests {
    private let noDependencies = DependenciesContainer()

    @Test func subflowsAreRegisteredWithTheirParent() async throws {
        let registry = try WorkflowRegistry([SatisfiedSubflowInputWorkflow()])

        #expect(await registry.allWorkflows().map(\.id) == ["NeedySubflow", "SatisfiedSubflowInputWorkflow"])
    }

    @Test func validWorkflowsPassStrictValidationAndGetGraphs() async throws {
        let registry = try WorkflowRegistry([LinearWorkflow(), SatisfiedSubflowInputWorkflow()])

        try await registry.validateAll(dependencies: noDependencies, mode: .strict)

        #expect(await registry.graph(for: "LinearWorkflow") != nil)
        #expect(await registry.graph(for: "NeedySubflow")?.requiredInputs.map(\.key) == ["requiredData"])
    }

    @Test func strictValidationThrowsOnlyTheInvalidWorkflows() async throws {
        let registry = try WorkflowRegistry([LinearWorkflow(), UndeclaredInputWorkflow(), UnusedInputWorkflow()])

        let failure = await #expect(throws: WorkflowsError.ValidationFailed.self) {
            try await registry.validateAll(dependencies: noDependencies, mode: .strict)
        }

        #expect(failure?.results.map(\.workflowId) == ["UndeclaredInputWorkflow"])
    }

    @Test func lenientValidationDoesNotThrowAndStillBuildsGraphs() async throws {
        let registry = try WorkflowRegistry([UndeclaredInputWorkflow()])

        try await registry.validateAll(dependencies: noDependencies, mode: .lenient)

        #expect(await registry.graph(for: "UndeclaredInputWorkflow") != nil)
    }

    @Test func circularSubflowsFailStrictValidation() async throws {
        let registry = try WorkflowRegistry([CircularAlpha()])

        let failure = await #expect(throws: WorkflowsError.CircularSubflows.self) {
            try await registry.validateAll(dependencies: noDependencies, mode: .strict)
        }

        let cycle = try #require(failure?.cycles.first)
        #expect(Set(cycle) == ["CircularAlpha", "CircularBeta"])
        #expect(cycle.first == cycle.last)
    }

    @Test func circularSubflowsAreToleratedInLenientMode() async throws {
        let registry = try WorkflowRegistry([CircularAlpha()])

        try await registry.validateAll(dependencies: noDependencies, mode: .lenient)
    }
}

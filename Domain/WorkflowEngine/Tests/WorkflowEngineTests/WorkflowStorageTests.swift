import Foundation
import Testing
@testable import WorkflowEngine

enum StorageKind: CaseIterable {
    case inMemory
    case jsonFile
}

private func temporaryDirectory() -> URL {
    FileManager.default.temporaryDirectory.appending(path: "WorkflowStorageTests-\(UUID().uuidString)")
}

private func makeStorage(_ kind: StorageKind, retentionInterval: TimeInterval = 3600) async throws -> any WorkflowStorage {
    switch kind {
        case .inMemory:
            InMemoryWorkflowStorage(retentionInterval: retentionInterval)
        case .jsonFile:
            try await JSONFileWorkflowStorage(directory: temporaryDirectory(), retentionInterval: retentionInterval)
    }
}

private let evictAtOnce: TimeInterval = -1

@Suite("Storage: shared behavior")
struct SharedStorageTests {
    @Test(arguments: StorageKind.allCases)
    func createStartsAnInstanceAtTheStartState(kind: StorageKind) async throws {
        let storage = try await makeStorage(kind)

        let instance = try await storage.create(LinearWorkflow(), initialData: WorkflowData(data: ["key": "value"]))

        #expect(!instance.id.isEmpty)
        #expect(instance.workflowId == "LinearWorkflow")
        #expect(instance.workflowVersion == 1)
        #expect(instance.state == "_start")
        #expect(instance.transitionState == nil)
        #expect(instance.data == WorkflowData(data: ["key": "value"]))
        #expect(instance.finishedAt == nil)
    }

    @Test(arguments: StorageKind.allCases)
    func everyCreateGetsItsOwnId(kind: StorageKind) async throws {
        let storage = try await makeStorage(kind)

        let first = try await storage.create(LinearWorkflow(), initialData: WorkflowData())
        let second = try await storage.create(LinearWorkflow(), initialData: WorkflowData())

        #expect(first.id != second.id)
        #expect(try await storage.all().map(\.id) == [first.id, second.id])
    }

    @Test(arguments: StorageKind.allCases)
    func instanceReturnsTheStoredInstanceOrNil(kind: StorageKind) async throws {
        let storage = try await makeStorage(kind)
        let created = try await storage.create(LinearWorkflow(), initialData: WorkflowData())

        let found = try await storage.instance(id: created.id)
        let missing = try await storage.instance(id: "no-such-id")

        #expect(found?.id == created.id)
        #expect(found?.state == "_start")
        #expect(missing == nil)
    }

    @Test(arguments: StorageKind.allCases)
    func updateReplacesTheInstanceAndMovesItLast(kind: StorageKind) async throws {
        let storage = try await makeStorage(kind)
        let first = try await storage.create(LinearWorkflow(), initialData: WorkflowData())
        let second = try await storage.create(LinearWorkflow(), initialData: WorkflowData())

        try await storage.update(first.moveToState("middle"))

        #expect(try await storage.instance(id: first.id)?.state == "middle")
        #expect(try await storage.all().map(\.id) == [second.id, first.id])
    }

    @Test(arguments: StorageKind.allCases)
    func updateOfAnUnknownInstanceAddsIt(kind: StorageKind) async throws {
        let storage = try await makeStorage(kind)
        let stranger = WorkflowInstance(
            id: "stranger",
            workflowId: "Elsewhere",
            workflowVersion: 7,
            state: "somewhere",
            transitionState: nil,
            data: WorkflowData()
        )

        try await storage.update(stranger)

        #expect(try await storage.instance(id: "stranger")?.workflowId == "Elsewhere")
        #expect(try await storage.all().map(\.id) == ["stranger"])
    }

    @Test(arguments: StorageKind.allCases)
    func finishedInstanceLeavesTheListButStaysReadableWithItsFinishDate(kind: StorageKind) async throws {
        let storage = try await makeStorage(kind)
        let instance = try await storage.create(LinearWorkflow(), initialData: WorkflowData())
        let other = try await storage.create(LinearWorkflow(), initialData: WorkflowData())

        try await storage.finish(instance.moveToState("_finish"))

        #expect(try await storage.all().map(\.id) == [other.id])
        let finished = try #require(try await storage.instance(id: instance.id))
        #expect(finished.state == "_finish")
        let finishedAt = try #require(finished.finishedAt)
        #expect(abs(finishedAt.timeIntervalSinceNow) < 5)
    }

    @Test(arguments: StorageKind.allCases)
    func finishedInstanceIsGoneOnceTheRetentionIntervalHasPassed(kind: StorageKind) async throws {
        let storage = try await makeStorage(kind, retentionInterval: evictAtOnce)
        let instance = try await storage.create(LinearWorkflow(), initialData: WorkflowData())
        let other = try await storage.create(LinearWorkflow(), initialData: WorkflowData())

        try await storage.finish(instance)

        #expect(try await storage.instance(id: instance.id) == nil)
        #expect(try await storage.all().map(\.id) == [other.id])
        #expect(try await storage.instance(id: other.id) != nil)
    }
}

@Suite("Storage: JSON files")
struct JSONFileStorageTests {
    let directory = temporaryDirectory()

    private func file(for id: WorkflowInstanceID) -> URL {
        directory.appending(path: "\(id).json")
    }

    @Test func createsTheDirectoryAndOneFilePerInstance() async throws {
        let storage = try await JSONFileWorkflowStorage(directory: directory)

        let first = try await storage.create(LinearWorkflow(), initialData: WorkflowData())
        let second = try await storage.create(LinearWorkflow(), initialData: WorkflowData())

        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path()).sorted()
        #expect(files == ["\(first.id).json", "\(second.id).json"].sorted())
    }

    @Test func filesArePrettyPrintedJSONWithSortedKeysAndISODates() async throws {
        let storage = try await JSONFileWorkflowStorage(directory: directory)
        let instance = try await storage.create(LinearWorkflow(), initialData: WorkflowData(data: ["b": "2", "a": "1"]))
        try await storage.finish(instance)

        let text = try String(contentsOf: file(for: instance.id), encoding: .utf8)

        let keys = text.split(separator: "\n").compactMap { line -> Substring? in
            let trimmed = line.drop { $0 == " " }
            guard trimmed.hasPrefix("\""), let quote = trimmed.dropFirst().firstIndex(of: "\"") else {
                return nil
            }
            return trimmed[trimmed.index(after: trimmed.startIndex)..<quote]
        }
        #expect(keys == ["data", "a", "b", "finishedAt", "id", "state", "workflowId", "workflowVersion"])
        let finishedAt = try #require(text.split(separator: "\n").first { $0.contains("finishedAt") })
        #expect(finishedAt.contains(#/"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z"/#))
    }

    @Test func updateRewritesTheFile() async throws {
        let storage = try await JSONFileWorkflowStorage(directory: directory)
        let instance = try await storage.create(LinearWorkflow(), initialData: WorkflowData())

        try await storage.update(instance.moveToState("middle").data(WorkflowData(data: ["k": "v"])))

        let decoded = try JSONDecoder().decode(WorkflowInstance.self, from: Data(contentsOf: file(for: instance.id)))
        #expect(decoded.state == "middle")
        #expect(decoded.data == WorkflowData(data: ["k": "v"]))
    }

    @Test func aNewStorageLoadsWhatThePreviousOneWrote() async throws {
        let first = try await JSONFileWorkflowStorage(directory: directory)
        let running = try await first.create(LinearWorkflow(), initialData: WorkflowData(data: ["k": "v"]))
        let finished = try await first.create(LinearWorkflow(), initialData: WorkflowData())
        try await first.update(running.moveToState("middle"))
        try await first.finish(finished)

        let second = try await JSONFileWorkflowStorage(directory: directory)

        #expect(try await second.all().map(\.id) == [running.id])
        #expect(try await second.instance(id: running.id)?.state == "middle")
        #expect(try await second.instance(id: running.id)?.data == WorkflowData(data: ["k": "v"]))
        #expect(try await second.instance(id: finished.id)?.finishedAt != nil)
    }

    @Test func aNewStorageKeepsTheLastWrittenOrder() async throws {
        let first = try await JSONFileWorkflowStorage(directory: directory)
        let older = try await first.create(LinearWorkflow(), initialData: WorkflowData())
        let newer = try await first.create(LinearWorkflow(), initialData: WorkflowData())
        try await Task.sleep(for: .milliseconds(20))
        try await first.update(older.moveToState("middle"))

        let second = try await JSONFileWorkflowStorage(directory: directory)

        #expect(try await second.all().map(\.id) == [newer.id, older.id])
    }

    @Test func aFailedWriteLeavesTheStorageUnchanged() async throws {
        let storage = try await JSONFileWorkflowStorage(directory: directory)
        let instance = try await storage.create(LinearWorkflow(), initialData: WorkflowData())
        try FileManager.default.removeItem(at: directory)

        await #expect(throws: (any Error).self) {
            try await storage.create(LinearWorkflow(), initialData: WorkflowData())
        }
        await #expect(throws: (any Error).self) {
            try await storage.update(instance.moveToState("middle"))
        }

        #expect(try await storage.all().map(\.id) == [instance.id])
        #expect(try await storage.instance(id: instance.id)?.state == "_start")
    }

    @Test func unreadableAndForeignFilesAreSkippedOnLoad() async throws {
        let first = try await JSONFileWorkflowStorage(directory: directory)
        let instance = try await first.create(LinearWorkflow(), initialData: WorkflowData())
        try Data("not json".utf8).write(to: file(for: "garbage"))
        try Data("{}".utf8).write(to: file(for: "incomplete"))
        try Data("ignored".utf8).write(to: directory.appending(path: "notes.txt"))

        let second = try await JSONFileWorkflowStorage(directory: directory)

        #expect(try await second.all().map(\.id) == [instance.id])
    }

    @Test func evictedInstanceLosesItsFile() async throws {
        let storage = try await JSONFileWorkflowStorage(directory: directory, retentionInterval: evictAtOnce)
        let instance = try await storage.create(LinearWorkflow(), initialData: WorkflowData())
        let other = try await storage.create(LinearWorkflow(), initialData: WorkflowData())

        try await storage.finish(instance)

        #expect(!FileManager.default.fileExists(atPath: file(for: instance.id).path()))
        #expect(FileManager.default.fileExists(atPath: file(for: other.id).path()))
    }

    @Test func expiredInstancesLoadedFromDiskAreEvictedOnFirstRead() async throws {
        let first = try await JSONFileWorkflowStorage(directory: directory)
        let instance = try await first.create(LinearWorkflow(), initialData: WorkflowData())
        try await first.finish(instance)

        let second = try await JSONFileWorkflowStorage(directory: directory, retentionInterval: evictAtOnce)

        #expect(try await second.instance(id: instance.id) == nil)
        #expect(!FileManager.default.fileExists(atPath: file(for: instance.id).path()))
    }
}

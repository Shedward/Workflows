//
//  JSONFileWorkflowStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 29.03.2026.
//

import Foundation

public actor JSONFileWorkflowStorage: WorkflowStorage {
    private static func load(from directory: URL) throws -> [WorkflowInstance] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let files = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        return files.compactMap { url in
            guard let data = try? Data(contentsOf: url) else {
                return nil
            }
            return try? decoder.decode(WorkflowInstance.self, from: data)
        }
    }

    private let directory: URL
    private let retentionInterval: TimeInterval
    private var instances: [WorkflowInstance] = []

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public init(directory: URL, retentionInterval: TimeInterval = 3600) async throws {
        self.directory = directory
        self.retentionInterval = retentionInterval
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.instances = try Self.load(from: directory)
    }

    public func create(_ workflow: AnyWorkflow, initialData: WorkflowData) throws -> WorkflowInstance {
        let instance = WorkflowInstance(
            id: UUID().uuidString,
            workflowId: workflow.id,
            state: workflow.startId,
            transitionState: nil,
            data: initialData
        )
        instances.append(instance)
        try save(instance)
        return instance
    }

    public func update(_ instance: WorkflowInstance) throws {
        instances = instances.filter { $0.id != instance.id } + [instance]
        try save(instance)
    }

    public func finish(_ instance: WorkflowInstance) throws {
        var finished = instance
        finished.finishedAt = Date()
        instances = instances.filter { $0.id != instance.id } + [finished]
        try save(finished)
        cleanupExpired()
    }

    public func all() -> [WorkflowInstance] {
        cleanupExpired()
        return instances.filter { $0.finishedAt == nil }
    }

    public func instance(id: WorkflowInstanceID) -> WorkflowInstance? {
        cleanupExpired()
        return instances.first { $0.id == id }
    }

    private func cleanupExpired() {
        let now = Date()
        instances.removeAll { instance in
            guard let finishedAt = instance.finishedAt else {
                return false
            }
            guard now.timeIntervalSince(finishedAt) > retentionInterval else {
                return false
            }
            try? FileManager.default.removeItem(at: filePath(for: instance.id))
            return true
        }
    }

    private func save(_ instance: WorkflowInstance) throws {
        let data = try encoder.encode(instance)
        try data.write(to: filePath(for: instance.id), options: .atomic)
    }

    private func filePath(for id: WorkflowInstanceID) -> URL {
        directory.appendingPathComponent("\(id).json")
    }
}

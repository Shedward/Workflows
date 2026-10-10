//
//  JSONFileWorkflowStorage.swift
//  WorkflowEngine
//

import Core
import Foundation
import os

public actor JSONFileWorkflowStorage: WorkflowStorage {
    private let directory: URL
    private let logger = Logger(scope: .workflow)
    private var table: WorkflowInstanceTable

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
        self.table = WorkflowInstanceTable(retentionInterval: retentionInterval)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try loadInstanceFiles()
    }

    public func create(_ workflow: AnyWorkflow, initialData: WorkflowData) throws -> WorkflowInstance {
        let instance = WorkflowInstance(atStartOf: workflow, data: initialData)
        table.put(instance)
        try save(instance)
        return instance
    }

    public func update(_ instance: WorkflowInstance) throws {
        table.put(instance)
        try save(instance)
    }

    public func finish(_ instance: WorkflowInstance) throws {
        let finished = instance.finished(at: Date())
        table.put(finished)
        try save(finished)
        removeExpired()
    }

    public func all() -> [WorkflowInstance] {
        removeExpired()
        return table.running
    }

    public func instance(id: WorkflowInstanceID) -> WorkflowInstance? {
        removeExpired()
        return table.instance(id: id)
    }

    private func loadInstanceFiles() throws {
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        for file in files where file.pathExtension == "json" {
            let contents: Data
            do {
                contents = try Data(contentsOf: file)
            } catch {
                logger?.error("Failed to read instance file \(file.lastPathComponent, privacy: .public): \(error, privacy: .public)")
                continue
            }
            do {
                table.put(try decoder.decode(WorkflowInstance.self, from: contents))
            } catch {
                logger?.error("Failed to decode instance file \(file.lastPathComponent, privacy: .public): \(error, privacy: .public)")
            }
        }
    }

    private func removeExpired() {
        for id in table.removeExpired() {
            do {
                try FileManager.default.removeItem(at: filePath(for: id))
            } catch {
                logger?.error("Failed to delete expired instance file \(id, privacy: .public): \(error, privacy: .public)")
            }
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

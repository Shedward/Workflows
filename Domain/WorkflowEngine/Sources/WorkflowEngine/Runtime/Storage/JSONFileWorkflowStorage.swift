//
//  JSONFileWorkflowStorage.swift
//  WorkflowEngine
//

import Core
import Foundation
import os

public actor JSONFileWorkflowStorage: WorkflowStorage {
    private static func load(from directory: URL, logger: Logger?) throws -> [WorkflowInstance] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let files = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        return files.compactMap { url in
            let data: Data
            do {
                data = try Data(contentsOf: url)
            } catch {
                logger?.error("Failed to read instance file \(url.lastPathComponent, privacy: .public): \(error, privacy: .public)")
                return nil
            }
            do {
                return try decoder.decode(WorkflowInstance.self, from: data)
            } catch {
                logger?.error("Failed to decode instance file \(url.lastPathComponent, privacy: .public): \(error, privacy: .public)")
                return nil
            }
        }
    }

    private let directory: URL
    private let logger = Logger(scope: .workflow)
    private var table: WorkflowInstanceTable

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    public init(directory: URL, retentionInterval: TimeInterval = 3600) async throws {
        self.directory = directory
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.table = WorkflowInstanceTable(
            instances: try Self.load(from: directory, logger: logger),
            retentionInterval: retentionInterval
        )
    }

    public func create(_ workflow: AnyWorkflow, initialData: WorkflowData) throws -> WorkflowInstance {
        let instance = WorkflowInstanceTable.newInstance(of: workflow, initialData: initialData)
        table.put(instance)
        try save(instance)
        return instance
    }

    public func update(_ instance: WorkflowInstance) throws {
        table.put(instance)
        try save(instance)
    }

    public func finish(_ instance: WorkflowInstance) throws {
        try save(table.finish(instance))
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

//
//  WorkflowStorage.swift
//
//
//  Created by Vlad Maltsev on 12.12.2023.
//

import LocalStorage
import FileSystem

public struct WorkflowStorage {
    public let data: CodableStorage
    public let rootItem: FileItem
    public let sharedItem: FileItem
    internal let deleteAllWorkflowData: () async throws -> Void
    
    init(
        data: CodableStorage,
        rootItem: FileItem,
        sharedItem: FileItem,
        deleteAllWorkflowData: @escaping () async throws -> Void
    ) {
        self.data = data
        self.rootItem = rootItem
        self.sharedItem = sharedItem
        self.deleteAllWorkflowData = deleteAllWorkflowData
    }
    
    public static var mock: WorkflowStorage {
        .init(
            data: InMemoryCodableStorage(),
            rootItem: InMemoryFileSystem().rootItem,
            sharedItem: InMemoryFileSystem().rootItem,
            deleteAllWorkflowData: { }
        )
    }
}

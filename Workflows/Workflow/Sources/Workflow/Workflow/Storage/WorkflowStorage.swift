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
    internal let deleteAllWorkflowData: () async throws -> Void
    
    init(
        data: CodableStorage,
        rootItem: FileItem,
        deleteAllWorkflowData: @escaping () async throws -> Void
    ) {
        self.data = data
        self.rootItem = rootItem
        self.deleteAllWorkflowData = deleteAllWorkflowData
    }
    
    public static var mock: WorkflowStorage {
        .init(
            data: InMemoryCodableStorage(),
            rootItem: InMemoryFileSystem().rootItem,
            deleteAllWorkflowData: { }
        )
    }
}

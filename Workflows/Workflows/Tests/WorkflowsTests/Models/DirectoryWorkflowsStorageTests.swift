//
//  DirectoryWorkflowsStorageTests.swift
//
//
//  Created by Vlad Maltsev on 23.10.2023.
//

@testable import Workflows
import XCTest

final class DirectoryWorkflowsStorageTests: XCTestCase {
    private var temporaryUrl: URL!
    private var storage: DirectoryWorkflowsStorage!
    
    override func setUp() async throws {
        let directory = NSTemporaryDirectory()
        temporaryUrl = URL(filePath: directory)
            .appending(path: "DirectoryWorkflowsStorageTests-" + UUID().uuidString)
        storage = DirectoryWorkflowsStorage(directory: temporaryUrl)
        try FileManager.default.createDirectory(at: temporaryUrl, withIntermediateDirectories: true)
    }
    
    override func tearDown() async throws {
        temporaryUrl = nil
    }
    
    func testEmptyWorkflowStorage() async throws {
        let workflows = try await storage.workflows()
        XCTAssertEqual(workflows.count, 0)
    }
    
    func testCreatingAndReading() async throws {
        let _ = try await storage.startWorkflow(name: "w1")
        let w2 = try await storage.startWorkflow(name: "w2")
        let _ = try await storage.startWorkflow(name: "w3")
        
        let workflows = try await storage.workflows()
        XCTAssertEqual(workflows.count, 3)
        
        let reopenW2 = try await storage.workflow(w2.id)
        XCTAssertEqual(w2.name, reopenW2.name)
    }
    
    func testWorkflowStorage() async throws {
        let workflow = try await storage.startWorkflow(name: "directory tests workflow")
        try workflow.storage.save("Hello workflow", at: "test")
        let savedData: String = try workflow.storage.load(at: "test")
        XCTAssertEqual(savedData, "Hello workflow")
    }
}

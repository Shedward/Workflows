// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Configuration
import Hummingbird
import Logging

public struct App {
    public static func main() async throws {
        let reader = try await ConfigReader(providers: [
            EnvironmentVariablesProvider(),
            EnvironmentVariablesProvider(environmentFilePath: ".env", allowMissing: true),
            InMemoryProvider(values: [
                "http.serverName": "workflow-server"
            ])
        ])
        let app = try await buildApplication(reader: reader)
        try await app.runService()
    }
}

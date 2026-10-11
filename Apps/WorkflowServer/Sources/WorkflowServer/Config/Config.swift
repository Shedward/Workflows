//
//  Config.swift
//  WorkflowServer
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import Configuration
import Foundation
import Logging

public struct Config {
    /// `HTTP_HOSTNAME`, `HTTP_PORT` and `LOG_LEVEL` from the process environment, then from `.env`,
    /// read once so that the bound address and every URL built from `baseURL` agree. The certificate
    /// and key are the ones `Tools/Run/setup_certs` writes into `~/.workflows/certs`.
    public static func load() async throws -> Config {
        let reader = try await ConfigReader(providers: [
            EnvironmentVariablesProvider(),
            EnvironmentVariablesProvider(environmentFilePath: ".env", allowMissing: true)
        ])
        let workflowsDirectory = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".workflows")
        let certificatesDirectory = workflowsDirectory.appending(path: "certs")
        return Config(
            hostname: reader.string(forKey: "http.hostname", default: "127.0.0.1"),
            port: reader.int(forKey: "http.port", default: 8443),
            logLevel: reader.string(forKey: "log.level", as: Logger.Level.self, default: .info),
            workflowsDirectory: workflowsDirectory,
            tlsCertificatePath: certificatesDirectory.appending(path: "localhost+2.pem").path(),
            tlsPrivateKeyPath: certificatesDirectory.appending(path: "localhost+2-key.pem").path()
        )
    }

    public var hostname: String
    public var port: Int
    public var logLevel: Logger.Level
    /// `~/.workflows`: certificates, the OAuth client file, persisted instances.
    public var workflowsDirectory: URL
    public var tlsCertificatePath: String
    public var tlsPrivateKeyPath: String

    public var baseURL: String {
        "https://\(hostname):\(port)"
    }

    public init(
        hostname: String,
        port: Int,
        logLevel: Logger.Level,
        workflowsDirectory: URL,
        tlsCertificatePath: String,
        tlsPrivateKeyPath: String
    ) {
        self.hostname = hostname
        self.port = port
        self.logLevel = logLevel
        self.workflowsDirectory = workflowsDirectory
        self.tlsCertificatePath = tlsCertificatePath
        self.tlsPrivateKeyPath = tlsPrivateKeyPath
    }
}

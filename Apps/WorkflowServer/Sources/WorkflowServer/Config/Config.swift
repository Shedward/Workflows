//
//  Config.swift
//  WorkflowServer
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import Foundation

public struct Config {
    public var hostname: String
    public var port: Int
    public var tlsCertificatePath: String
    public var tlsPrivateKeyPath: String

    public init(
        hostname: String = "127.0.0.1",
        port: Int = 8443,
        tlsCertificatePath: String,
        tlsPrivateKeyPath: String
    ) {
        self.hostname = hostname
        self.port = port
        self.tlsCertificatePath = tlsCertificatePath
        self.tlsPrivateKeyPath = tlsPrivateKeyPath
    }

    /// Uses the certificate and key that `Tools/Run/setup_certs` writes into `certificatesDirectory`.
    public init(hostname: String = "127.0.0.1", port: Int = 8443, certificatesDirectory: URL) {
        self.init(
            hostname: hostname,
            port: port,
            tlsCertificatePath: certificatesDirectory.appending(path: "localhost+2.pem").path(),
            tlsPrivateKeyPath: certificatesDirectory.appending(path: "localhost+2-key.pem").path()
        )
    }
}

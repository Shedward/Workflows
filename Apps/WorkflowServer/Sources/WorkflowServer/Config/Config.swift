//
//  Config.swift
//  WorkflowServer
//
//  Created by Мальцев Владислав on 02.04.2026.
//

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
}

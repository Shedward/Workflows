//
//  ExecutableOutput.swift
//
//
//  Created by Vlad Maltsev on 20.01.2024.
//

import Foundation
import AsyncAlgorithms
import Combine

public final class ExecutableLogs {
    
    public struct LogLine {
        public enum Kind {
            case normal
            case error
        }
        
        public let kind: Kind
        public let text: String
    }
    
    fileprivate let outputPipe: Pipe
    fileprivate let errorPipe: Pipe
    private var logsSubject = PassthroughSubject<LogLine, Never>()
    
    public var logs: AnyPublisher<LogLine, Never> {
        logsSubject
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public init() {
        self.outputPipe = Pipe()
        self.errorPipe = Pipe()
        startObserving()
    }
    
    private func startObserving() {
        outputPipe.fileHandleForReading.readabilityHandler = { handler in
            Task(priority: .userInitiated) {
                for try await line in handler.bytes.lines {
                    self.logsSubject.send(LogLine(kind: .normal, text: line))
                }
            }
        }
        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            Task(priority: .userInitiated) {
                for try await line in handler.bytes.lines {
                    self.logsSubject.send(LogLine(kind: .error, text: line))
                }
            }
        }
    }
}

extension Executable {
    public func logs(to logs: ExecutableLogs?) -> Self {
        guard let logs else { return self }
        return output(to: logs.outputPipe)
            .errorOutput(to: logs.errorPipe)
    }
}

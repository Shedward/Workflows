//
//  ReportFatalAndExit.swift
//  Core
//

import Foundation

public func reportFatalAndExit(_ error: any Error) -> Never {
    let message = (error as? DescriptiveError)?.userDescription ?? "\(error)"
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

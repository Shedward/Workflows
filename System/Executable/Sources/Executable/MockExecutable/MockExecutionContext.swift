//
//  MockExecutionContext.swift
//
//
//  Created by Vlad Maltsev on 01.10.2023.
//

import Prelude

public struct MockExecutionContext: CustomStringConvertible {
    let workingDirectory: String?
    let arguments: [String]
    let environment: [String : String]
    let pipes: ExecutablePipes
    
    public var description: String {
        """
        MockExecutionContext(
          workingDirectory: \(workingDirectory ?? "nil")
          arguments: \(arguments),
          environment: \(environment)
        )
        """
    }
}

public struct MockExecutionFilter {
    var workingDirectory: ValueFilter<String?>
    var arguments: ValueFilter<[String]>
    var environment: ValueFilter<[String : String]>
    
    public static func any() -> MockExecutionFilter {
        .init()
    }
    
    public init(
        workingDirectory: ValueFilter<String?> = .any(),
        arguments: ValueFilter<[String]> = .any(),
        environment: ValueFilter<[String : String]> = .any()
    ) {
        self.workingDirectory = workingDirectory
        self.arguments = arguments
        self.environment = environment
    }
    
    func matching(_ context: MockExecutionContext) -> Bool {
        workingDirectory.matching(context.workingDirectory)
        && arguments.matching(context.arguments)
        && environment.matching(context.environment)
    }
}


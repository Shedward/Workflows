//
//  GitMock.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import Executable

public struct GitMock {
    let executable: MockExecutable
    
    public init() {
        self.executable = MockExecutable(label: "git")
    }
}

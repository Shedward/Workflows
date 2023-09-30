//
//  GitMock.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import Executable

struct GitMock {
    let executable: MockExecutable
    
    init() {
        self.executable = MockExecutable(label: "git")
    }
}

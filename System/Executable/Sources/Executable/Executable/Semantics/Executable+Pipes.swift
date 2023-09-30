//
//  Executable+Pipes.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

extension Executable {
    public func input(to pipe: ExecutablePipe?) -> Self {
        var executable = self
        executable.pipes.input = pipe
        return executable
    }
    
    public func output(to pipe: ExecutablePipe?) -> Self {
        var executable = self
        executable.pipes.output = pipe
        return executable
    }
    
    public func errorOutput(to pipe: ExecutablePipe?) -> Self {
        var executable = self
        executable.pipes.output = pipe
        return executable
    }
}

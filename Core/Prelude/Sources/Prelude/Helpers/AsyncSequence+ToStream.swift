//
//  AsyncSequence+ToStream.swift
//
//
//  Created by Vlad Maltsev on 20.01.2024.
//

extension AsyncSequence {
    public func toAsyncThrowingStream() -> AsyncThrowingStream<Element, Error> {
        var iterator = makeAsyncIterator()
        
        return AsyncThrowingStream {
            try await iterator.next()
        }
    }
}

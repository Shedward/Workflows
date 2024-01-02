//
//  LoadingProgress.swift
//
//
//  Created by Vlad Maltsev on 02.01.2024.
//

public enum Progress {
    public struct Value {
        public let progress: Float?
        public let message: String?
        
        public init(progress: Float? = nil, message: String? = nil) {
            self.progress = progress
            self.message = message
        }
    }
    
    case progress(Value)
    case failed(String)
    
    public static func progress(progress: Float? = nil, message: String? = nil) -> Self {
        .progress(Value(progress: progress, message:  message))
    }
}

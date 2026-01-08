//
//  Method+HTTPRequest.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import RestClient
import Hummingbird

extension Method {
    var httpRequestMethod: HTTPRequest.Method {
        switch self {
            case .get: return .get
            case .post: return .post
            case .put: return .put
            case .delete: return .delete
            case .patch: return .patch
        }
    }
}

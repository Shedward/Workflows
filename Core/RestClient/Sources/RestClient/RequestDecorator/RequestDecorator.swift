//
//  RequestDecorator.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import Foundation

public protocol RequestDecorator {
    func request<Request: RestBodyEncodable, Response: RestBodyDecodable>(
        from request: RestRequest<Request, Response>
    ) async throws -> RestRequest<Request, Response>
}

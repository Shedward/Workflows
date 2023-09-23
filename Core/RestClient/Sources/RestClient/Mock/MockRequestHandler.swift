//
//  MockRequestHandler.swift
//
//
//  Created by v.maltsev on 23.09.2023.
//

public protocol MockRequestHandler {
    associatedtype RequestBody: RestBodyEncodable
    associatedtype ResponseBody: RestBodyDecodable

    func shouldAcceptRequest(_ request: RestRequest<RequestBody, ResponseBody>) -> Bool
    func response(for request: RestRequest<RequestBody, ResponseBody>) throws -> ResponseBody
}

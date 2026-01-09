//
//  Api.swift
//  Rest
//
//  Created by Vlad Maltsev on 23.12.2025.
//

public protocol Api: Sendable {
    associatedtype RequestBody: DataEncodable = EmptyBody
    associatedtype ResponseBody: DataDecodable = EmptyBody

    typealias RouteRequest = Request<RequestBody, ResponseBody>

    var request: RouteRequest { get }
}

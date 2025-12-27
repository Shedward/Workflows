//
//  Method.swift
//  RestClient
//
//  Created by Vlad Maltsev on 21.12.2025.
//

public enum Method: String, Sendable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

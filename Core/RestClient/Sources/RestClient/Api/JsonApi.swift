//
//  JsonApi.swift
//  RestClient
//
//  Created by Vlad Maltsev on 23.12.2025.
//

public protocol JsonApi: Api, JSONEncodableBody where RequestBody == Self {
}

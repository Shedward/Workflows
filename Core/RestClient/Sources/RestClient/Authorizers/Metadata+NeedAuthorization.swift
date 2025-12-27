//
//  Metadata+NeedAuthorization.swift
//  RestClient
//
//  Created by Vlad Maltsev on 23.12.2025.
//

import Core

enum NeedAuthorizedMetadataKey: MetadataKey {
    static let defaultValue = true
}

extension Request {
    public func authorised(_ isAuthorised: Bool) -> Self {
        metadata(NeedAuthorizedMetadataKey.self, to: isAuthorised)
    }
}

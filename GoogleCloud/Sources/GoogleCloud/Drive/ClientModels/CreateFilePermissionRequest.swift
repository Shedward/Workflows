//
//  CreateFilePermissionRequest.swift
//
//
//  Created by v.maltsev on 30.08.2023.
//

import RestClient

struct CreateFilePermissionRequest: JSONEncodableBody, Equatable {
    var type: String
    var role: String
    var emailAddress: String?
    var domain: String?

    init(type: String, role: String, emailAddress: String?, domain: String?) {
        self.type = type
        self.role = role
        self.emailAddress = emailAddress
        self.domain = domain
    }

    init(createPermission: CreateFilePermission) {
        switch createPermission.group {
        case .user(let emailAddress):
            self.type = "user"
            self.emailAddress = emailAddress
        case .group(let emailAddress):
            self.type = "group"
            self.emailAddress = emailAddress
        case .domain(let domain):
            self.type = "domain"
            self.domain = domain
        case .anyone:
            self.type = "anyone"
        }

        switch createPermission.role {
        case .organizer:
            self.role = "organizer"
        case .fileOrganizer:
            self.role = "fileOrganizer"
        case .writer:
            self.role = "writer"
        case .commenter:
            self.role = "commenter"
        case .reader:
            self.role = "reader"
        }
    }
}

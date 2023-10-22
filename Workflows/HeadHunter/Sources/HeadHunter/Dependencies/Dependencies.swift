//
//  Dependencies.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import GoogleCloud
import Jira
import LocalStorage
import Git

public protocol GoogleDriveDependency {
    var googleDrive: GoogleDrive { get set }
}

public protocol GoogleSheetsDependency {
    var googleSheets: GoogleSheets { get set }
}

public protocol GoogleAuthorizerDependency {
    var googleAuthorizer: GoogleAuthorizer { get set }
}

public typealias AllGoogleCloudDependencies =
    GoogleDriveDependency
    & GoogleSheetsDependency
    & GoogleAuthorizerDependency

public protocol JiraAuthorizerDependency {
    var jiraAuthorizer: JiraAuthorizer { get set }
}

public protocol JiraDependency {
    var jira: Jira { get }
}

public typealias AllJiraDependencies =
    JiraDependency
    & JiraAuthorizerDependency

public protocol ConfigStorageDependency {
    var configStorage: CodableStorage { get set }
}

public protocol GitDependency {
    var git: Git { get set }
}

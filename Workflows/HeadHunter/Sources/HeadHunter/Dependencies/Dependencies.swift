//
//  Dependencies.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

import GoogleCloud
import LocalStorage

public protocol GoogleDriveDependency {
    var googleDrive: GoogleDrive { get set }
}

public protocol GoogleSheetsDependency {
    var googleSheets: GoogleSheets { get set }
}

public protocol GoogleAuthorizerDependency {
    var googleAuthorizer: GoogleCloud.Authorizer { get set }
}

public protocol ConfigStorageDependency {
    var configStorage: ConfigStorage { get set }
}

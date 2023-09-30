//
//  MockDependencies.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import HeadHunter
@testable import GoogleCloud
@testable import Jira

typealias AllMockDependencies =
    GoogleDriveDependency
    & GoogleSheetsDependency
    & JiraDependency

struct Mocks {
    let googleDrive = GoogleDriveMock()
    let googleSheets = GoogleSheetsMock()
    let jira = JiraMock()
}

struct MockDependencies: AllMockDependencies {
    var googleDrive: GoogleDrive
    var googleSheets: GoogleSheets
    var jira: Jira
    
    init(mocks: Mocks) {
        googleDrive = .init(mock: mocks.googleDrive)
        googleSheets = .init(mock: mocks.googleSheets)
        jira = .init(mock: mocks.jira)
    }
}

//
//  MockDependencies.swift
//
//
//  Created by Vlad Maltsev on 30.09.2023.
//

import HeadHunter
@testable import GoogleCloud
@testable import Jira
@testable import Git

typealias AllMockDependencies =
    GoogleDriveDependency
    & GoogleSheetsDependency
    & JiraDependency
    & GitDependency

struct Mocks {
    let googleDrive = GoogleDriveMock()
    let googleSheets = GoogleSheetsMock()
    let jira = JiraMock()
    let git = GitMock()
}

struct MockDependencies: AllMockDependencies {
    var googleDrive: GoogleDrive
    var googleSheets: GoogleSheets
    var jira: Jira
    var git: Git
    
    init(mocks: Mocks) {
        googleDrive = .init(mock: mocks.googleDrive)
        googleSheets = .init(mock: mocks.googleSheets)
        jira = .init(mock: mocks.jira)
        git = .init(mock: mocks.git)
    }
}

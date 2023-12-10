//
//  Navigations.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI

@Observable
final class Navigation {
    let id: String
    var path = NavigationPath()
    
    init(id: String = #fileID) {
        self.id = id
        self.path = path
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

//
//  DependenciesKey.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI

struct DependenciesEnvironmentKey: EnvironmentKey {

    static var defaultValue: AllDependencies = NetworkDependencies()
}

extension EnvironmentValues {
    var dependencies: AllDependencies {
        get { self[DependenciesEnvironmentKey.self] }
        set { self[DependenciesEnvironmentKey.self] = newValue }
    }
}

extension View {
    func dependencies(_ dependencies: AllDependencies) -> some View {
        environment(\.dependencies, dependencies)
    }
}

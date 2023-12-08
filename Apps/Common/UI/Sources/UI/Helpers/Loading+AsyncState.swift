//
//  Loading+AsyncState.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI
import Prelude

extension State {
    
    public func assignAsync<Success>(_ call: () async throws -> Success) async where Value == Loading<Success, Error> {
        self.wrappedValue = .loading
        do {
            self.wrappedValue = .loaded(try await call())
        } catch {
            self.wrappedValue = .failure(error)
        }
    }
}

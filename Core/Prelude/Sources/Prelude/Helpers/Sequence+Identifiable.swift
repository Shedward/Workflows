//
//  Sequence+Identifiable.swift
//
//
//  Created by Vlad Maltsev on 04.12.2023.
//

import Foundation

public extension Sequence where Element: Identifiable {
    
    func first(id: Element.ID) -> Element? {
        first { $0.id == id }
    }
}

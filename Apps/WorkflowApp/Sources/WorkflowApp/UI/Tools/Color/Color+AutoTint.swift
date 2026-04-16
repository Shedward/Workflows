//
//  Color+AutoTint.swift
//  WorkflowApp
//
//  Created by Мальцев Владислав on 16.04.2026.
//

import SwiftUI

extension Color {

    private static let autoTintPalette: [Color] = [
        .red, .orange, .yellow, .green, .mint,
        .teal, .cyan, .blue, .indigo, .purple, .pink, .brown,
    ]

    init(hash value: some Hashable) {
        // djb2 hash — deterministic across launches (Swift's Hasher is randomly seeded per process).
        var hash: UInt64 = 5381
        for byte in String(describing: value).utf8 {
            hash = hash &* 33 &+ UInt64(byte)
        }
        let index = Int(hash % UInt64(Self.autoTintPalette.count))
        self = Self.autoTintPalette[index]
    }
}

extension Identifiable {
    var tint: Color {
        Color(hash: id)
    }
}

extension Hashable {
    var tint: Color {
        Color(hash: self)
    }
}

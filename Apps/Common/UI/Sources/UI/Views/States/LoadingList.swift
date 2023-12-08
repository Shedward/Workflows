//
//  LoadingList.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI
import Prelude

public struct LoadingList<Item: Identifiable, Cell: View, Empty: View>: View {
    
    @State
    private var items: Loading<[Item], Error> = .loading

    private let cell: (Item) -> Cell
    private let load: () async throws -> [Item]
    private let empty: () -> Empty
    
    public init(
        cell: @escaping (Item) -> Cell,
        load: @escaping () async throws -> [Item],
        empty: @escaping () -> Empty
    ) {
        self.cell = cell
        self.load = load
        self.empty = empty
    }
    
    public var body: some View {
        List {
            switch items {
            case .loading:
                LoadingView()
            case .loaded(let items):
                if items.isEmpty {
                    empty()
                } else {
                    ForEach(items) { item in
                        cell(item)
                    }
                }
            case .failure(let error):
                FailureView(error)
            }
        }
        .task { await reload() }
        .refreshable { await reload() }
    }
    
    private func reload() async {
        await _items.assignAsync {
            try await load()
        }
    }
}

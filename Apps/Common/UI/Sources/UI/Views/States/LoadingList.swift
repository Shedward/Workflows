//
//  LoadingList.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI
import Prelude
import Combine

@Observable
public final class LoadingListViewModel<Item: Identifiable> {
    
    public var shouldShowLoading: Bool = false
    
    internal var items: Loading<[Item], Error> = .loading
    private let load: () async throws -> [Item]
    
    public init(_ load: @escaping () async throws -> [Item]) {
        self.load = load
    }
    
    public func reload() async {
        if shouldShowLoading {
            self.items = .loading
        }
        do {
            self.items = .loaded(try await load())
        } catch {
            self.items = .failure(error)
        }
    }
    
    public func reload() {
        Task {
            await reload()
        }
    }
    
    public func showLoading(_ shouldShowLoading: Bool) -> Self {
        self.shouldShowLoading = shouldShowLoading
        return self
    }
}

public struct LoadingList<Item: Identifiable, Cell: View, Empty: View>: View {

    var viewModel: LoadingListViewModel<Item>?

    private let cell: (Item) -> Cell
    private let empty: () -> Empty
    
    private var contentInsets = EdgeInsets()
    
    public init(
        viewModel: LoadingListViewModel<Item>?,
        cell: @escaping (Item) -> Cell,
        empty: @escaping () -> Empty
    ) {
        self.cell = cell
        self.viewModel = viewModel
        self.empty = empty
    }
    
    public var body: some View {
        List {
            if contentInsets.top > 0 {
                Rectangle()
                    .fill(.clear)
                    .frame(height: contentInsets.top)
            }
            
            switch viewModel?.items ?? .loading {
            case .loading:
                if viewModel?.shouldShowLoading ?? false {
                    LoadingView()
                }
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
            
            if contentInsets.bottom > 0 {
                Rectangle()
                    .fill(.clear)
                    .frame(height: contentInsets.bottom)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always)
        .task {
            await viewModel?.reload()
        }
    }
    
    public func contentInsets(
        top: CGFloat = 0,
        bottom: CGFloat = 0
    ) -> Self {
        var view = self
        view.contentInsets.top = top
        view.contentInsets.bottom = bottom
        return view
    }
}

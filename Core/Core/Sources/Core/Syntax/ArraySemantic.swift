//
//  ArraySemantic.swift
//  Core
//
//  Created by Vlad Maltsev on 21.12.2025.
//

public protocol ArraySemantic {
    associatedtype Item

    var items: [Item] { get set }
}

extension ArraySemantic {
    public subscript (_ index: Int) -> Item {
        get { items[index] }
        set { items[index] = newValue }
    }

    public var isEmpty: Bool {
        items.isEmpty
    }
}

extension Modifiers where Self: ArraySemantic {
    mutating public func append(_ item: Item) {
        items.append(item)
    }

    public func appending(_ item: Item) -> Self {
        with { $0.append(item) }
    }
}

extension Modifiers where Self: Defaultable, Self: ArraySemantic {

    public init(_ item: Item) {
        self = Self().appending(item)
    }
}

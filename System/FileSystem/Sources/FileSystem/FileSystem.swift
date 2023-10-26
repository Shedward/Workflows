//
//  FileSystem.swift
//
//
//  Created by Vlad Maltsev on 23.10.2023.
//

import Foundation

public protocol FileSystem {
    func item(at path: Path) -> FileItem
    func items(at path: Path) throws -> [FileItem]
    func itemExists(at path: Path) -> Bool
    
    func deleteItem(at path: Path) throws
    func loadData(at path: Path) throws -> Data
}

//
//  IssuesPageDynamicKeys.swift
//  Created by Vladislav Maltsev on 28.07.2023.
//

import Foundation
import Prelude

enum IssuesPageDynamicKeys: PageResponseDynamicKeys {
    static let items = ArbitraryCodingKey(stringValue: "issues")
}

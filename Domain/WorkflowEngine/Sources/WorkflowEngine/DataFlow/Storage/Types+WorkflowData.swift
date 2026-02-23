//
//  Types+WorkflowData.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 10.01.2026.
//

import Foundation

extension String: WorkflowValue { }
extension Float: WorkflowValue { }
extension Int: WorkflowValue { }
extension Bool: WorkflowValue { }
extension URL: WorkflowValue { }

extension Array: WorkflowValue where Element: WorkflowValue { }
extension Dictionary: WorkflowValue where Key: WorkflowValue, Value: WorkflowValue { }
extension Set: WorkflowValue where Element: WorkflowValue { }

extension Optional: WorkflowValue where Wrapped: WorkflowValue { }

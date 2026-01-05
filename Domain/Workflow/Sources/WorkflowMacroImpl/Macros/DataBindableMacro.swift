//
//  WorkflowIO.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftLexicalLookup

private enum WrapperKind {
    case input(key: String)
    case output(key: String)
    case dependency(key: String)

    var methodName: String {
        switch self {
        case .input: return "input"
        case .output: return "output"
        case .dependency: return "dependency"
        }
    }

    var key: String {
        switch self {
        case .input(let k), .output(let k), .dependency(let k):
            return k
        }
    }
}

private struct Field {
    let name: String
    let type: TypeSyntax
    let kind: WrapperKind
}

public struct DataBindableMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        let members = declaration.memberBlock.members

        var statements: [CodeBlockItemSyntax] = []

        for member in members {
            guard let field = Self.extractField(from: member) else { continue }
            statements.append(Self.makeStatement(from: field))
        }

        let body = CodeBlockItemListSyntax(statements)

        let method: DeclSyntax =
        """
        mutating func bind(_ bind: inout any DataBinding) throws {
            \(body)
        }
        """

        return [method]
    }

    private static func extractField(from member: MemberBlockItemSyntax) -> Field? {
        guard
            let varDecl = member.decl.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
            let type = binding.typeAnnotation?.type
        else {
            return nil
        }

        let propertyName = identifier.identifier.text
        let attributes = varDecl.attributes

        for attribute in attributes {
            let attrName: String
            if let simple = attribute.as(AttributeSyntax.self) {
                attrName = simple.attributeName.trimmedDescription
            } else {
                continue
            }

            switch attrName {
            case "Input":
                let key = Self.extractKey(from: attribute) ?? propertyName
                return Field(name: propertyName, type: type, kind: .input(key: key))

            case "Output":
                let key = Self.extractKey(from: attribute) ?? propertyName
                return Field(name: propertyName, type: type, kind: .output(key: key))

            case "Dependency":
                let key = Self.extractKey(from: attribute) ?? propertyName
                return Field(name: propertyName, type: type, kind: .dependency(key: key))

            default:
                continue
            }
        }

        return nil
    }

    private static func extractKey(from attr: SyntaxProtocol) -> String? {
        if let simple = attr.as(AttributeSyntax.self) {
            guard
                let args = simple.arguments?.as(LabeledExprListSyntax.self),
                let keyArg = args.first(where: { $0.label?.text == "key" }),
                let literal = keyArg.expression.as(StringLiteralExprSyntax.self)
            else {
                return nil
            }

            return literal.segments
                .compactMap { $0.as(StringSegmentSyntax.self)?.content.text }
                .joined()
        } else {
            return nil
        }
    }

    private static func makeStatement(from field: Field) -> CodeBlockItemSyntax {
        """
        try bind.\(raw: field.kind.methodName)(for: "\(raw: field.kind.key)", at: &_\(raw: field.name))
        """
    }
}


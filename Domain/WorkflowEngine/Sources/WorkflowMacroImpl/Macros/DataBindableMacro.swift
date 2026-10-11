//
//  WorkflowIO.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

private struct Field {
    let name: String
    let key: String
    let bindingMethod: String
}

public struct DataBindableMacro: MemberMacro {

    private static let bindingMethods = [
        "Input": "input",
        "Output": "output",
        "Dependency": "dependency",
        "Ask": "ask"
    ]

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {

        let members = declaration.memberBlock.members

        var statements: [CodeBlockItemSyntax] = []

        for member in members {
            guard let field = Self.extractField(from: member) else { continue }
            statements.append(Self.makeStatement(from: field))
        }

        let body = CodeBlockItemListSyntax(statements)

        let accessKeywords: Set<String> = ["public", "open", "internal", "fileprivate", "private"]
        let accessLevel = declaration.modifiers
            .first { accessKeywords.contains($0.name.text) }
            .map { $0.name.text + " " } ?? ""

        let method: DeclSyntax =
        """
        \(raw: accessLevel)mutating func bind<Binding: DataBinding>(_ bind: inout Binding) throws {
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
            binding.typeAnnotation != nil
        else {
            return nil
        }

        let propertyName = identifier.identifier.text

        for attribute in varDecl.attributes {
            guard
                let attribute = attribute.as(AttributeSyntax.self),
                let bindingMethod = bindingMethods[attribute.attributeName.trimmedDescription]
            else {
                continue
            }
            return Field(
                name: propertyName,
                key: extractKey(from: attribute) ?? propertyName,
                bindingMethod: bindingMethod
            )
        }

        return nil
    }

    private static func extractKey(from attribute: AttributeSyntax) -> String? {
        guard
            let args = attribute.arguments?.as(LabeledExprListSyntax.self),
            let keyArg = args.first(where: { $0.label?.text == "key" }),
            let literal = keyArg.expression.as(StringLiteralExprSyntax.self)
        else {
            return nil
        }

        return literal.segments
            .compactMap { $0.as(StringSegmentSyntax.self)?.content.text }
            .joined()
    }

    private static func makeStatement(from field: Field) -> CodeBlockItemSyntax {
        """
        try bind.\(raw: field.bindingMethod)(for: "\(raw: field.key)", at: &_\(raw: field.name))
        """
    }
}

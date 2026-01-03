import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

struct InputMacroError: DiagnosticMessage {
    let message: String

    var diagnosticID: MessageID {
        .init(domain: "WorkflowMacros", id: "InputMacro")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

public struct InputMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard
            let varDecl = declaration.as(VariableDeclSyntax.self),
            varDecl.bindings.count == 1,
            let binding = varDecl.bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
        else {
            context.diagnose(Diagnostic(node: node, message: InputMacroError(message: "'@Input' can only be applied to a stored property")))
            return []
        }

        let propertyName = pattern.identifier.text

        if node.arguments != nil {
            return []
        }

        let inputDecl: DeclSyntax = """
        @Input(key: "\(raw: propertyName)") var \(raw: propertyName): Int
        """

        return [
            inputDecl
        ]
    }
}

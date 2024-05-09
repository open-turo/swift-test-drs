//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SetStubReturningOutputMacro: ExpressionMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let output = node.arguments.last?.expression else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic.unknown
                )
            )
            return ""
        }

        if let memberAccess = node.arguments.first?.expression.as(MemberAccessExprSyntax.self), let base = memberAccess.base {
            return """
            \(base).setStub(for: \(memberAccess), withSignature: "\(memberAccess.declName.baseName)\(memberAccess.resolvedArguments)", returning: \(output))
            """
        } else if let expression = node.arguments.first?.expression.as(DeclReferenceExprSyntax.self) {
            return """
            setStub(for: \(expression), withSignature: "\(expression.argumentNames == nil ? "\(expression)()" : "\(expression)")", returning: \(output))
            """
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic.unknown
                )
            )
            return ""
        }
    }
}

public struct SetStubThrowingErrorMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let error = node.arguments.last?.expression else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic.unknown
                )
            )
            return ""
        }

        if let memberAccess = node.arguments.first?.expression.as(MemberAccessExprSyntax.self), let base = memberAccess.base {
            return """
            \(base).setStub(for: \(memberAccess), withSignature: "\(memberAccess.declName.baseName)\(memberAccess.resolvedArguments)", throwing: \(error))
            """
        } else if let expression = node.arguments.first?.expression.as(DeclReferenceExprSyntax.self) {
            return """
            setStub(for: \(expression), withSignature: "\(expression.argumentNames == nil ? "\(expression)()" : "\(expression)")", throwing: \(error))
            """
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic.unknown
                )
            )
            return ""
        }
    }
}

public struct SetStubUsingClosureMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let closure = node.arguments.last?.expression else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic.unknown
                )
            )
            return ""
        }

        if let memberAccess = node.arguments.first?.expression.as(MemberAccessExprSyntax.self), let base = memberAccess.base {
            return """
            \(base).setDynamicStub(for: \(memberAccess), withSignature: "\(memberAccess.declName.baseName)\(memberAccess.resolvedArguments)")\(closure)
            """
        } else if let expression = node.arguments.first?.expression.as(DeclReferenceExprSyntax.self) {
            return """
            setDynamicStub(for: \(expression), withSignature: "\(expression.argumentNames == nil ? "\(expression)()" : "\(expression)")")\(closure)
            """
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic.unknown
                )
            )
            return ""
        }
    }
}

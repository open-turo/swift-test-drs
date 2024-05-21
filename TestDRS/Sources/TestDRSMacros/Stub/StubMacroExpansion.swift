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
        guard node.arguments.count == 2,
              let firstArgument = node.arguments.first?.expression,
              let output = node.arguments.last?.expression
        else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic(
                        issue: .incorrectArguments,
                        macro: Self.self
                    )
                )
            )
            return ""
        }

        if let memberAccess = firstArgument.as(MemberAccessExprSyntax.self), let base = memberAccess.base {
            return """
            \(base).setStub(for: \(memberAccess), withSignature: "\(memberAccess.declName.withArguments())", returning: \(output))
            """
        } else if let expression = firstArgument.as(DeclReferenceExprSyntax.self) {
            return """
            setStub(for: \(expression), withSignature: "\(expression.argumentNames == nil ? "\(expression)()" : "\(expression)")", returning: \(output))
            """
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic(issue: .unableToResolveMember, macro: Self.self)
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
        guard node.arguments.count == 2,
              let firstArgument = node.arguments.first?.expression,
              let error = node.arguments.last?.expression
        else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic(
                        issue: .incorrectArguments,
                        macro: Self.self
                    )
                )
            )
            return ""
        }

        if let memberAccess = firstArgument.as(MemberAccessExprSyntax.self), let base = memberAccess.base {
            return """
            \(base).setStub(for: \(memberAccess), withSignature: "\(memberAccess.declName.withArguments())", throwing: \(error))
            """
        } else if let expression = firstArgument.as(DeclReferenceExprSyntax.self) {
            return """
            setStub(for: \(expression), withSignature: "\(expression.argumentNames == nil ? "\(expression)()" : "\(expression)")", throwing: \(error))
            """
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic(issue: .unableToResolveMember, macro: Self.self)
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
        guard node.arguments.count == 2,
              let firstArgument = node.arguments.first?.expression,
              let closure = node.arguments.last?.expression
        else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic(
                        issue: .incorrectArguments,
                        macro: Self.self
                    )
                )
            )
            return ""
        }

        if let memberAccess = firstArgument.as(MemberAccessExprSyntax.self), let base = memberAccess.base {
            return """
            \(base).setDynamicStub(for: \(memberAccess), withSignature: "\(memberAccess.declName.withArguments())")\(closure)
            """
        } else if let expression = firstArgument.as(DeclReferenceExprSyntax.self) {
            return """
            setDynamicStub(for: \(expression), withSignature: "\(expression.argumentNames == nil ? "\(expression)()" : "\(expression)")")\(closure)
            """
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: StubExpansionDiagnostic(issue: .unableToResolveMember, macro: Self.self)
                )
            )
            return ""
        }
    }
}

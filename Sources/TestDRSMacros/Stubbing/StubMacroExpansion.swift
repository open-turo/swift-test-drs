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
        guard (2 ... 3).contains(node.arguments.count),
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

        let inputType = node.arguments.first { argument in
            argument.label?.text == "taking"
        }?.expression

        if let memberAccess = firstArgument.as(MemberAccessExprSyntax.self)?.trimmed, let base = memberAccess.base {
            return """
            \(base).setStub(for: \(memberAccess), withSignature: \(literal: memberAccess.declName.description), taking: \(inputType == nil ? "nil" : "\(inputType)"), returning: \(output))
            """
        } else if let expression = firstArgument.as(DeclReferenceExprSyntax.self)?.trimmed {
            return """
            setStub(for: \(expression), withSignature: \(literal: expression.description), taking: \(inputType == nil ? "nil" : "\(inputType)"), returning: \(output))
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
        guard (2 ... 3).contains(node.arguments.count),
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

        let inputType = node.arguments.first { argument in
            argument.label?.text == "taking"
        }?.expression

        if let memberAccess = firstArgument.as(MemberAccessExprSyntax.self)?.trimmed, let base = memberAccess.base {
            return """
            \(base).setStub(for: \(memberAccess), withSignature: \(literal: memberAccess.declName.description), taking: \(inputType == nil ? "nil" : "\(inputType)"), throwing: \(error))
            """
        } else if let expression = firstArgument.as(DeclReferenceExprSyntax.self)?.trimmed {
            return """
            setStub(for: \(expression), withSignature: \(literal: expression.description), taking: \(inputType == nil ? "nil" : "\(inputType)"), throwing: \(error))
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

        if let memberAccess = firstArgument.as(MemberAccessExprSyntax.self)?.trimmed, let base = memberAccess.base {
            return """
            \(base).setDynamicStub(for: \(memberAccess), withSignature: \(literal: memberAccess.declName.description), using: \(closure))
            """
        } else if let expression = firstArgument.as(DeclReferenceExprSyntax.self)?.trimmed {
            return """
            setDynamicStub(for: \(expression), withSignature: \(literal: expression.description), using: \(closure))
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

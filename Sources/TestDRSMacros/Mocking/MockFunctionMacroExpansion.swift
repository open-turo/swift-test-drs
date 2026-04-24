//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MockFunctionMacro: BodyMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        if let method = declaration as? FunctionDeclSyntax {
            guard method.body == nil else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(node),
                        message: MockFunctionExpansionDiagnostic.existingBody
                    )
                )
                return []
            }
            return CodeBlockItemListSyntax {
                recordCallSyntax(for: method)
                ReturnStmtSyntax(expression: stubOutputSyntax(for: method))
            }.map { $0 }
        }

        return []
    }

    private static func stubOutputSyntax(for method: FunctionDeclSyntax) -> ExprSyntax {
        let callee = switch (method.isAsync, method.isThrowing) {
        case (true, true): "asyncThrowingStubOutput"
        case (true, false): "asyncStubOutput"
        case (false, true): "throwingStubOutput"
        case (false, false): "stubOutput"
        }

        let call = FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: callee)) {
            if method.hasParameters {
                LabeledExprSyntax(
                    label: "for",
                    expression: method.inputParameters
                )
            }
        }

        let tryPrefix = method.isThrowing ? "try " : ""
        let awaitPrefix = method.isAsync ? "await " : ""
        return ExprSyntax(stringLiteral: "\(tryPrefix)\(awaitPrefix)\(call.trimmedDescription)")
    }

    private static func recordCallSyntax(for method: FunctionDeclSyntax) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: "recordCall")) {
            if method.hasParameters {
                LabeledExprSyntax(label: "with", expression: method.inputParameters)
            }

            if let returnClause = method.signature.returnClause {
                LabeledExprSyntax(
                    label: "returning",
                    expression: ExprSyntax(stringLiteral: "\(returnClause.type.trimmed).self")
                )
            }
        }
    }

}

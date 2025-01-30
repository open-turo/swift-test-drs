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
        FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: method.isThrowing ? "throwingStubOutput" : "stubOutput")) {
            if method.hasParameters {
                LabeledExprSyntax(
                    label: "for",
                    expression: method.inputParameters
                )
            }
        }
        .wrappedInTry(method.isThrowing)
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

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
        of node: SwiftSyntax.AttributeSyntax,
        providingBodyFor declaration: some SwiftSyntax.DeclSyntaxProtocol & SwiftSyntax.WithOptionalCodeBlockSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
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
            return mockMethodBody(for: method).statements.map { $0 }
        }

        return []
    }

    static func mockMethodBody(for method: FunctionDeclSyntax) -> CodeBlockSyntax {
        CodeBlockSyntax(
            leftBrace: .leftBraceToken(),
            statements: CodeBlockItemListSyntax {
                recordCallSyntax(for: method)
                ReturnStmtSyntax(expression: stubOutputSyntax(for: method))
            },
            rightBrace: .rightBraceToken()
        )
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

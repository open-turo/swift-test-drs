//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SpyFunctionMacro: BodyMacro {

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
                        message: SpyFunctionExpansionDiagnostic.existingBody
                    )
                )
                return []
            }

            // Extract delegate type name argument (e.g., "RealType" for protocols, "SomeStruct" for structs)
            guard let delegateTypeName = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression
                .as(StringLiteralExprSyntax.self)?
                .segments.first?.as(StringSegmentSyntax.self)?
                .content.text else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(node),
                        message: SpyFunctionExpansionDiagnostic.missingDelegateTypeName
                    )
                )
                return []
            }

            return CodeBlockItemListSyntax {
                recordCallSyntax(for: method)
                if method.signature.returnClause != nil {
                    ReturnStmtSyntax(expression: realDelegationSyntax(for: method, delegateTypeName: delegateTypeName))
                } else {
                    ExpressionStmtSyntax(expression: realDelegationSyntax(for: method, delegateTypeName: delegateTypeName))
                }
            }.map { $0 }
        }

        return []
    }

    private static func realDelegationSyntax(for method: FunctionDeclSyntax, delegateTypeName: String) -> ExprSyntax {
        let isClassMember = method.isClassMember
        let isStaticMember = method.isStatic && !isClassMember
        let isOverride = method.isOverride

        let targetPrefix = spyDelegationTarget(
            isOverride: isOverride,
            isClassMember: isClassMember,
            isStaticMember: isStaticMember,
            delegateTypeName: delegateTypeName
        )

        let methodCall = FunctionCallExprSyntax(
            callee: MemberAccessExprSyntax(
                base: ExprSyntax(stringLiteral: targetPrefix),
                period: .periodToken(),
                declName: DeclReferenceExprSyntax(baseName: method.name.trimmed)
            )
        ) {
            for parameter in method.signature.parameterClause.parameters {
                let argumentLabel: TokenSyntax? = parameter.firstName.tokenKind == .wildcard ? nil : parameter.firstName
                let parameterName = parameter.secondName ?? parameter.firstName

                LabeledExprSyntax(
                    label: argumentLabel,
                    colon: argumentLabel == nil ? nil : .colonToken(),
                    expression: DeclReferenceExprSyntax(baseName: parameterName)
                )
            }
        }

        var expr = ExprSyntax(methodCall)
        if method.isAsync {
            expr = ExprSyntax(AwaitExprSyntax(expression: expr))
        }
        if method.isThrowing {
            expr = ExprSyntax(TryExprSyntax(expression: expr))
        }
        return expr
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

extension FunctionDeclSyntax {
    var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }
}

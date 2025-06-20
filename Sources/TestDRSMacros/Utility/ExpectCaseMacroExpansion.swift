//
// Created on 6/6/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum MacroExpansionError: Error, CustomStringConvertible {
    case missingArguments

    var description: String {
        switch self {
        case .missingArguments:
            return "Missing required arguments"
        }
    }
}

public struct ExpectCaseMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let caseArgument = node.arguments.first else {
            throw MacroExpansionError.missingArguments
        }

        guard let valueArgument = node.arguments.dropFirst().first else {
            throw MacroExpansionError.missingArguments
        }

        let casePattern = caseArgument.expression.trimmed
        let valueExpression = valueArgument.expression.trimmed

        guard let caseName = extractCaseName(from: casePattern) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(caseArgument),
                    message: ExpectCaseExpansionDiagnostic.invalidCasePattern
                )
            )
            return ExprSyntax(stringLiteral: "")
        }

        let switchStatement = buildSwitchStatement(
            valueExpression: valueExpression,
            casePattern: casePattern,
            caseName: caseName
        )

        return ExprSyntax(
            FunctionCallExprSyntax(
                calledExpression: ExprSyntax(
                    ClosureExprSyntax(
                        leftBrace: .leftBraceToken(),
                        statements: CodeBlockItemListSyntax([
                            CodeBlockItemSyntax(item: .expr(ExprSyntax(switchStatement)))
                        ]),
                        rightBrace: .rightBraceToken()
                    )
                ),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax([]),
                rightParen: .rightParenToken()
            )
        )
    }

    private static func extractCaseName(from expression: ExprSyntax) -> String? {
        if let memberAccess = expression.as(MemberAccessExprSyntax.self) {
            return memberAccess.declName.baseName.text
        }

        if let functionCall = expression.as(FunctionCallExprSyntax.self),
           let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self) {
            return memberAccess.declName.baseName.text
        }

        return nil
    }

    private static func buildSwitchStatement(
        valueExpression: ExprSyntax,
        casePattern: ExprSyntax,
        caseName: String
    ) -> SwitchExprSyntax {
        let expectedCase = SwitchCaseSyntax(
            label: .case(
                SwitchCaseLabelSyntax(
                    caseItems: SwitchCaseItemListSyntax([
                        SwitchCaseItemSyntax(
                            pattern: ExpressionPatternSyntax(expression: casePattern)
                        )
                    ])
                )
            ),
            statements: CodeBlockItemListSyntax([
                CodeBlockItemSyntax(
                    item: .stmt(StmtSyntax(BreakStmtSyntax()))
                )
            ])
        )

        let defaultCase = SwitchCaseSyntax(
            label: .default(SwitchDefaultLabelSyntax()),
            statements: CodeBlockItemListSyntax([
                CodeBlockItemSyntax(
                    item: .stmt(
                        StmtSyntax(
                            ExpressionStmtSyntax(
                                expression: FunctionCallExprSyntax(
                                    calledExpression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier("_expectCaseFailure"))),
                                    leftParen: .leftParenToken(),
                                    arguments: LabeledExprListSyntax([
                                        LabeledExprSyntax(
                                            label: "expectedCase",
                                            colon: .colonToken(),
                                            expression: StringLiteralExprSyntax(content: casePattern.description),
                                            trailingComma: .commaToken()
                                        ),
                                        LabeledExprSyntax(
                                            label: "actualValue",
                                            colon: .colonToken(),
                                            expression: valueExpression
                                        )
                                    ]),
                                    rightParen: .rightParenToken()
                                )
                            )
                        )
                    )
                )
            ])
        )

        return SwitchExprSyntax(
            subject: valueExpression,
            leftBrace: .leftBraceToken(),
            cases: SwitchCaseListSyntax([
                SwitchCaseListSyntax.Element(expectedCase),
                SwitchCaseListSyntax.Element(defaultCase)
            ]),
            rightBrace: .rightBraceToken()
        )
    }

}

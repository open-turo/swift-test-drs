//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol SpyAssertionMacro: ExpressionMacro {
    static var instanceAssertionName: String { get }
    static var staticAssertionName: String { get }
}

public struct AssertWasCalledMacro: SpyAssertionMacro {
    static let instanceAssertionName = "assertWasCalled"
    // TODO: There seems to a bug in macro expansion that necessitates static assertions having a different name,
    // we should see if it is possible to use the same name at some point.
    static let staticAssertionName = "assertStaticFunctionWasCalled"
}

public struct AssertWasNotCalledMacro: SpyAssertionMacro {
    static let instanceAssertionName = "assertWasNotCalled"
    static let staticAssertionName = "assertStaticFunctionWasNotCalled"
}

extension SpyAssertionMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let function = node.arguments.first!.expression.trimmed
        let additionalArguments = node.arguments.dropFirst().map { argument in
            var argument = argument

            if argument.label?.text == "with" {
                argument = argument.with(\.label, "expectedInput")
            }

            return argument.trimmed
        }

        guard let assertionSyntax = assertWasCalledSyntax(
            from: function,
            forAssertion: Self.self,
            additionalArguments: additionalArguments
        ) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: SpyAssertionExpansionDiagnostic(issue: .unableToResolveFunction, macro: Self.self)
                )
            )
            return ""
        }

        return assertionSyntax
    }

    static func assertWasCalledSyntax(
        from expression: ExprSyntax,
        forAssertion assertion: SpyAssertionMacro.Type,
        fileAndLine: (ExprSyntax, ExprSyntax)? = nil,
        additionalArguments: [LabeledExprSyntax] = []
    ) -> ExprSyntax? {
        var arguments = additionalArguments

        if let (file, line) = fileAndLine {
            arguments.append(LabeledExprSyntax(label: "file", expression: file))
            arguments.append(LabeledExprSyntax(label: "line", expression: line))
        }

        // Functions with a base are parsed as MemberAccessExprSyntax
        // Eg. mock.foo
        // or: mock.bar(paramOne:)
        if let memberAccess = expression.as(MemberAccessExprSyntax.self) {
            return ExprSyntax(
                assertionFunctionCall(
                    memberAccess: memberAccess,
                    function: memberAccess.declName,
                    forAssertion: assertion,
                    arguments: arguments
                )
            )
        }

        // Functions without a base and are parsed as DeclReferenceExprSyntax
        // eg. foo
        // or: foo(paramOne:)
        if let reference = expression.as(DeclReferenceExprSyntax.self) {
            return ExprSyntax(
                assertionFunctionCall(
                    function: reference,
                    forAssertion: assertion,
                    arguments: arguments
                )
            )
        }

        return nil
    }

    private static func assertionFunctionCall(
        memberAccess: MemberAccessExprSyntax? = nil,
        function: DeclReferenceExprSyntax,
        forAssertion assertion: SpyAssertionMacro.Type,
        arguments: [LabeledExprSyntax]
    ) -> FunctionCallExprSyntax {
        let leadingTrivia: Trivia = arguments.isEmpty ? [] : .newline

        let memberAccessOrFunction: ExprSyntax
        let callee: ExprSyntax

        if var memberAccess {
            memberAccessOrFunction = ExprSyntax(memberAccess)

            if "\(memberAccess)".first?.isUppercase == true {
                memberAccess.declName.baseName = .identifier(assertion.staticAssertionName)
            } else {
                memberAccess.declName.baseName = .identifier(assertion.instanceAssertionName)
            }

            memberAccess.declName.argumentNames = nil
            callee = ExprSyntax(memberAccess)
        } else {
            memberAccessOrFunction = ExprSyntax(function)
            callee = ExprSyntax(stringLiteral: assertion.instanceAssertionName)
        }

        return FunctionCallExprSyntax(callee: callee) {
            LabeledExprSyntax(expression: memberAccessOrFunction)
                .with(\.leadingTrivia, leadingTrivia)

            LabeledExprSyntax(
                label: "withSignature",
                expression: ExprSyntax(stringLiteral: "\"\(function)\"")
            )
            .with(\.leadingTrivia, leadingTrivia)

            for argument in arguments {
                argument.with(\.leadingTrivia, leadingTrivia)
            }
        }
        .with(\.rightParen, .rightParenToken(leadingTrivia: leadingTrivia))
    }

}

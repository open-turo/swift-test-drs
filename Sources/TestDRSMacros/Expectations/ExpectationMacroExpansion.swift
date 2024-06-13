//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol ExpectationMacro: ExpressionMacro {
    static var instanceExpectationName: String { get }
    static var staticExpectationName: String { get }
}

public struct ExpectWasCalledMacro: ExpectationMacro {
    static let instanceExpectationName = "expectWasCalled"
    // TODO: There seems to a bug in macro expansion that necessitates static expectations having a different name,
    // we should see if it is possible to use the same name at some point.
    static let staticExpectationName = "expectStaticFunctionWasCalled"
}

public struct ExpectWasNotCalledMacro: ExpectationMacro {
    static let instanceExpectationName = "expectWasNotCalled"
    static let staticExpectationName = "expectStaticFunctionWasNotCalled"
}

extension ExpectationMacro {

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

        guard let expectationSyntax = expectWasCalledSyntax(
            from: function,
            forExpectation: Self.self,
            additionalArguments: additionalArguments
        ) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: ExpectationExpansionDiagnostic(issue: .unableToResolveFunction, macro: Self.self)
                )
            )
            return ""
        }

        return expectationSyntax
    }

    static func expectWasCalledSyntax(
        from expression: ExprSyntax,
        forExpectation expectation: ExpectationMacro.Type,
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
                expectationFunctionCall(
                    memberAccess: memberAccess,
                    function: memberAccess.declName,
                    forExpectation: expectation,
                    arguments: arguments
                )
            )
        }

        // Functions without a base and are parsed as DeclReferenceExprSyntax
        // eg. foo
        // or: foo(paramOne:)
        if let reference = expression.as(DeclReferenceExprSyntax.self) {
            return ExprSyntax(
                expectationFunctionCall(
                    function: reference,
                    forExpectation: expectation,
                    arguments: arguments
                )
            )
        }

        return nil
    }

    private static func expectationFunctionCall(
        memberAccess: MemberAccessExprSyntax? = nil,
        function: DeclReferenceExprSyntax,
        forExpectation expectation: ExpectationMacro.Type,
        arguments: [LabeledExprSyntax]
    ) -> FunctionCallExprSyntax {
        let leadingTrivia: Trivia = arguments.isEmpty ? [] : .newline

        let memberAccessOrFunction: ExprSyntax
        let callee: ExprSyntax

        if var memberAccess {
            memberAccessOrFunction = ExprSyntax(memberAccess)

            if "\(memberAccess)".first?.isUppercase == true {
                memberAccess.declName.baseName = .identifier(expectation.staticExpectationName)
            } else {
                memberAccess.declName.baseName = .identifier(expectation.instanceExpectationName)
            }

            memberAccess.declName.argumentNames = nil
            callee = ExprSyntax(memberAccess)
        } else {
            memberAccessOrFunction = ExprSyntax(function)
            callee = ExprSyntax(stringLiteral: expectation.instanceExpectationName)
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

//
// Created on 1/13/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Expands macros that verify function calls to transform a reference to the function into a reference and a function signature. The reference to the function must be the first argument in the macro.
///
/// For example, the following macro:
/// ```
/// #verification(mock.foo(paramOne:), with: "Hello World")
/// ```
/// expands to:
/// ```
/// verification(
///     mock.foo(paramOne:),
///     withSignature: "foo(paramOne:),
///     expectedInput: "Hello World"
/// )
/// ```
protocol FunctionCallVerificationMacro: ExpressionMacro {

    /// The name of the verification to use when called on an instance of a type.
    static var instanceVerificationName: String { get }
    /// The name of the verification to use when called on a type.
    static var staticVerificationName: String { get }
    /// The label to use before the function argument, eg. in `confirmationOfCall(to: foo)`, "to" would be the function argument label.
    static var functionArgumentLabel: String? { get }
    /// A map of argument labels to replace when expanding the macro, where the key is the argument label in the macro and the value is the argument label that it should expand into.
    static var argumentLabelReplacements: [String: TokenSyntax] { get }

}

/// Default implementations
extension FunctionCallVerificationMacro {

    static var functionArgumentLabel: String? { nil }
    static var argumentLabelReplacements: [String: TokenSyntax] { ["with": "expectedInput"] }

}

extension FunctionCallVerificationMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let function = node.arguments.first!.expression.trimmed
        let additionalArguments = node.arguments.dropFirst().map { argument in
            var argument = argument

            if let argumentLabel = argument.label?.text, let replacementArgumentLabel = argumentLabelReplacements[argumentLabel] {
                argument = argument.with(\.label, replacementArgumentLabel)
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
                    message: FunctionCallVerificationDiagnostic(issue: .unableToResolveFunction, macro: Self.self)
                )
            )
            return ""
        }

        return expectationSyntax
    }

    static func expectWasCalledSyntax(
        from expression: ExprSyntax,
        forExpectation expectation: FunctionCallVerificationMacro.Type,
        additionalArguments: [LabeledExprSyntax] = []
    ) -> ExprSyntax? {
        let arguments = additionalArguments

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
        forExpectation expectation: FunctionCallVerificationMacro.Type,
        arguments: [LabeledExprSyntax]
    ) -> FunctionCallExprSyntax {
        let leadingTrivia: Trivia = arguments.isEmpty ? [] : .newline

        let memberAccessOrFunction: ExprSyntax
        let callee: ExprSyntax

        if var memberAccess {
            memberAccessOrFunction = ExprSyntax(memberAccess)

            if "\(memberAccess)".first?.isUppercase == true {
                memberAccess.declName.baseName = .identifier(expectation.staticVerificationName)
            } else {
                memberAccess.declName.baseName = .identifier(expectation.instanceVerificationName)
            }

            memberAccess.declName.argumentNames = nil
            callee = ExprSyntax(memberAccess)
        } else {
            memberAccessOrFunction = ExprSyntax(function)
            callee = ExprSyntax(stringLiteral: expectation.instanceVerificationName)
        }

        return FunctionCallExprSyntax(callee: callee) {
            LabeledExprSyntax(label: expectation.functionArgumentLabel, expression: memberAccessOrFunction)
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

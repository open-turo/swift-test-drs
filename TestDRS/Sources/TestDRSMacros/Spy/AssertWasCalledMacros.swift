//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol AssertMethodOrCallMacro: ExpressionMacro {
    static var name: String { get }
}

public struct AssertWasCalledMacro: AssertMethodOrCallMacro {
    static let name = "assertWasCalled"
}

public struct AssertWasNotCalledMacro: AssertMethodOrCallMacro {
    static let name = "assertWasNotCalled"
}

public struct AssertWasCalledFirstMacro: AssertMethodOrCallMacro {
    static let name = "assertWasCalledFirst"
}

public struct AssertWasCalledLastMacro: AssertMethodOrCallMacro {
    static let name = "assertWasCalledLast"
}

public struct AssertWasCalledExactlyOnceMacro: AssertMethodOrCallMacro {
    static let name = "assertWasCalledExactlyOnce"
}

extension AssertMethodOrCallMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let expression = node.arguments.first!.expression

        guard let assertionSyntax = assertWasCalledSyntax(
            from: expression,
            forAssertion: Self.self
        ) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: SpyAssertionDiagnostic.noValidFunctionOrCall(macroName: name)
                )
            )
            return ""
        }

        return assertionSyntax
    }

    static func assertWasCalledSyntax(
        from expression: ExprSyntax,
        forAssertion assertion: AssertMethodOrCallMacro.Type,
        fileAndLine: (ExprSyntax, ExprSyntax)? = nil,
        additionalArguments: [LabeledExprSyntax] = []
    ) -> ExprSyntax? {
        var arguments = additionalArguments
        if let (file, line) = fileAndLine {
            arguments.append(LabeledExprSyntax(label: "file", expression: file))
            arguments.append(LabeledExprSyntax(label: "line", expression: line))
        }

        // Function calls are parsed as FunctionCallExprSyntax
        // Eg. mock.foo()
        // or: mock.bar(paramOne: "Hello")
        if let functionCall = expression.as(FunctionCallExprSyntax.self) {
            return ExprSyntax(
                assertionFunctionCall(
                    from: functionCall,
                    forAssertion: assertion,
                    arguments: arguments
                )
            )
        }

        // Functions themselves are parsed as MemberAccessExprSyntax
        // Eg. mock.foo
        // or: mock.bar(paramOne:)
        if let memberAccess = expression.as(MemberAccessExprSyntax.self) {
            return ExprSyntax(
                assertionFunctionCall(
                    from: memberAccess,
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
                    from: reference,
                    forAssertion: assertion,
                    arguments: arguments
                )
            )
        }

        return nil
    }

    private static func assertionFunctionCall(
        from functionCall: FunctionCallExprSyntax,
        forAssertion assertion: AssertMethodOrCallMacro.Type,
        arguments: [LabeledExprSyntax]
    ) -> FunctionCallExprSyntax {
        let callee: ExprSyntax

        if let memberAccess = functionCall.memberAccessWithoutBaseName {
            callee = ExprSyntax(stringLiteral: "\(memberAccess)\(assertion.name)")
        } else {
            callee = ExprSyntax(stringLiteral: assertion.name)
        }

        return FunctionCallExprSyntax(callee: callee) {
            LabeledExprSyntax(
                expression: ExprSyntax(stringLiteral: "\"\(functionCall.signature)\"")
            )
            if !functionCall.arguments.isEmpty {
                for (index, argument) in functionCall.arguments.enumerated() {
                    argument
                        .with(\.label, index == 0 ? "with" : nil)
                        .with(\.colon, index == 0 ? .colonToken() : nil)
                }
            }
            for argument in arguments {
                argument
            }
        }
    }

    private static func assertionFunctionCall(
        from memberAccess: MemberAccessExprSyntax,
        forAssertion assertion: AssertMethodOrCallMacro.Type,
        arguments: [LabeledExprSyntax]
    ) -> FunctionCallExprSyntax {
        var callee = memberAccess
        callee.declName.baseName = .identifier(assertion.name)
        callee.declName.argumentNames = nil

        return FunctionCallExprSyntax(callee: callee) {
            LabeledExprSyntax(
                expression: ExprSyntax(stringLiteral: "\"\(memberAccess.declName.withArguments())\"")
            )
            for argument in arguments {
                argument
            }
        }
    }

    private static func assertionFunctionCall(
        from reference: DeclReferenceExprSyntax,
        forAssertion assertion: AssertMethodOrCallMacro.Type,
        arguments: [LabeledExprSyntax]
    ) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: assertion.name)) {
            LabeledExprSyntax(
                expression: ExprSyntax(stringLiteral: "\"\(reference.withArguments())\"")
            )
            for argument in arguments {
                argument
            }
        }
    }
}

enum SpyAssertionDiagnostic: DiagnosticMessage {
    case noValidFunctionOrCall(macroName: String)

    var message: String {
        switch self {
        case .noValidFunctionOrCall(let macroName):
            return """
            #\(macroName) requires either a reference to a function like `mock.foo` or `mock.bar(paramOne:)`, or a function call like `mock.foo()` or `mock.bar(paramOne:"Hello World")
            """
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: macroName, id: id)
    }

    var severity: DiagnosticSeverity { .error }

    private var macroName: String {
        switch self {
        case .noValidFunctionOrCall(let macroName):
            return macroName
        }
    }

    private var id: String {
        switch self {
        case .noValidFunctionOrCall:
            return "no valid function or function call"
        }
    }
}

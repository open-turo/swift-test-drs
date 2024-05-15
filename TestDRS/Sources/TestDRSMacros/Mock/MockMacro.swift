//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MockMacro: PeerMacro {

    private static let spyProtocolName = "Spy"
    private static let stubProvidingProtocolName = "StubProviding"

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let mockDeclaration: DeclSyntax

        if let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) {
            mockDeclaration = DeclSyntax(try mockClassDeclaration(from: protocolDeclaration))
        } else if let classDeclaration = declaration.as(ClassDeclSyntax.self) {
            mockDeclaration = DeclSyntax(try mockSubclassDeclaration(from: classDeclaration))
        } else if let structDeclaration = declaration.as(StructDeclSyntax.self) {
            mockDeclaration = DeclSyntax(try mockStruct(from: structDeclaration))
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: MockExpansionDiagnostic.invalidType
                )
            )
            return []
        }

        return [
            DeclSyntax(
                try IfConfigDeclSyntax.ifDebug {
                    mockDeclaration
                        .with(\.leadingTrivia, .newlines(2))
                        .with(\.trailingTrivia, .newlines(2))
                }
            )
        ]
    }

    private static func mockClassDeclaration(from protocolDeclaration: ProtocolDeclSyntax) throws -> ClassDeclSyntax {
        let protocolName = protocolDeclaration.name.trimmed.text

        // Check if the protocol is marked with @objc, if so, the mock class will need to inherit from NSObject
        let nsObject = protocolDeclaration.attributes.trimmedDescription.contains("@objc") ? "NSObject" : nil

        var classDeclaration = try mockClass(
            named: protocolName,
            inheritanceClause: .emptyClause.appending(
                [nsObject, protocolName, spyProtocolName, stubProvidingProtocolName]
                    .compactMap { $0 }
            ),
            members: protocolDeclaration.memberBlock.members,
            isSubclass: false
        )

        if let associatedTypeClause = protocolDeclaration.primaryAssociatedTypeClause {
            classDeclaration.genericParameterClause = GenericParameterClauseSyntax(
                leftAngle: .leftAngleToken(),
                parameters: GenericParameterListSyntax {
                    for associatedType in associatedTypeClause.primaryAssociatedTypes {
                        GenericParameterSyntax(name: associatedType.name)
                    }
                },
                rightAngle: .rightAngleToken()
            )
        }
        classDeclaration.modifiers += protocolDeclaration.modifiers
        classDeclaration.attributes = protocolDeclaration.attributes
            .filter { $0.trimmedDescription != "@Mock" }

        return classDeclaration
    }

    private static func mockSubclassDeclaration(from classDeclaration: ClassDeclSyntax) throws -> ClassDeclSyntax {
        let className = classDeclaration.name.trimmed.text

        return try mockClass(
            named: className,
            inheritanceClause: .emptyClause.appending([className, spyProtocolName, stubProvidingProtocolName]),
            members: classDeclaration.memberBlock.members,
            isSubclass: true
        )
    }

    private static func mockStruct(from structDeclaration: StructDeclSyntax) throws -> StructDeclSyntax {
        var mockStructDeclaration = structDeclaration.trimmed
        mockStructDeclaration.memberBlock.rightBrace.leadingTrivia = []

        mockStructDeclaration.memberBlock.members = mockMembers(
            from: structDeclaration.memberBlock.members,
            forClass: false,
            shouldOverride: false
        )
        mockStructDeclaration.name = mockTypeName(from: structDeclaration.name.trimmedDescription)
        mockStructDeclaration.inheritanceClause = (structDeclaration.inheritanceClause ?? .emptyClause).appending([spyProtocolName, stubProvidingProtocolName])

        mockStructDeclaration.modifiers = structDeclaration.modifiers
        mockStructDeclaration.attributes = structDeclaration.attributes
            .filter { $0.trimmedDescription != "@Mock" }

        return mockStructDeclaration
    }

    private static func mockClass(
        named typeName: String,
        inheritanceClause: InheritanceClauseSyntax? = nil,
        members: MemberBlockItemListSyntax,
        isSubclass: Bool = false
    ) throws -> ClassDeclSyntax {
        return ClassDeclSyntax(
            modifiers: DeclModifierListSyntax(
                [DeclModifierSyntax(name: .keyword(.final))]
            ),
            name: mockTypeName(from: typeName),
            inheritanceClause: inheritanceClause
        ) {
            mockMembers(from: members, forClass: true, shouldOverride: isSubclass)
        }
    }

    private static func mockTypeName(from typeName: String) -> TokenSyntax {
        TokenSyntax.identifier("Mock\(typeName)")
    }

    private static func mockMembers(
        from members: MemberBlockItemListSyntax,
        forClass: Bool,
        shouldOverride: Bool
    ) -> MemberBlockItemListSyntax {
        let mockProperties = members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { !$0.isPrivate && !($0.isStatic && shouldOverride) }
            .compactMap { mockProperty(for: $0, shouldAddOverrideModifier: shouldOverride) }

        let mockMethods = members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .filter { !$0.isPrivate && !($0.isStatic && shouldOverride) }
            .compactMap { mockMethod(for: $0, isInClass: forClass, shouldAddOverrideModifier: shouldOverride) }

        let mockTypes = members.filter { $0.decl.isTypeDeclaration }

        return MemberBlockItemListSyntax {
            mockTypes
            DeclSyntax("let blackBox = BlackBox()")
                .with(\.leadingTrivia, .newlines(2))
            DeclSyntax("let stubRegistry = StubRegistry()")
            DeclSyntax("static let blackBox = BlackBox()")
            DeclSyntax("static let stubRegistry = StubRegistry()")
            MemberBlockItemListSyntax {
                for mockProperty in mockProperties {
                    mockProperty
                        .with(\.leadingTrivia, .newlines(2))
                }
            }
            .with(\.leadingTrivia, .newlines(2))
            MemberBlockItemListSyntax {
                for mockMethod in mockMethods {
                    mockMethod
                        .with(\.leadingTrivia, .newlines(2))
                }
            }
            .with(\.trailingTrivia, Trivia(pieces: [.newlines(1), .spaces(1)]))
        }
    }

    private static func mockProperty(for property: VariableDeclSyntax, shouldAddOverrideModifier: Bool) -> VariableDeclSyntax {
        var mockProperty = property.trimmed

        if shouldAddOverrideModifier && !mockProperty.isOverride {
            mockProperty.modifiers.append(
                DeclModifierSyntax(name: .keyword(.override))
            )
        }

        mockProperty.bindingSpecifier = .keyword(.var)

        mockProperty.bindings = PatternBindingListSyntax {
            for binding in mockProperty.bindings {
                binding
                    .with(\.initializer, nil)
                    .with(\.accessorBlock, (mockPropertyAccessor(isStatic: mockProperty.isStatic || mockProperty.isClassMember)))
            }
        }

        return mockProperty
    }

    private static func mockPropertyAccessor(isStatic: Bool) -> AccessorBlockSyntax {
        let getter = AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
            "stubOutput()"
        }
        let setter = AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
            "setStub(value: newValue)"
        }
        return AccessorBlockSyntax(
            leftBrace: .leftBraceToken(),
            accessors: .accessors(
                AccessorDeclListSyntax {
                    getter
                    setter
                }
            ),
            rightBrace: .rightBraceToken()
        )
    }

    private static func mockMethod(
        for method: FunctionDeclSyntax,
        isInClass: Bool,
        shouldAddOverrideModifier: Bool
    ) -> FunctionDeclSyntax? {
        var mockMethod = method.trimmed

        if isInClass {
            mockMethod = removeMutatingModifierIfNeeded(from: mockMethod)
        }
        if shouldAddOverrideModifier {
            mockMethod = addOverrideModifierIfNeeded(to: mockMethod)
        }

        mockMethod.body = mockMethodBody(
            for: mockMethod,
            returningExpression: returningExpression(for: method)
        )

        return mockMethod
    }

    private static func addOverrideModifierIfNeeded(to method: FunctionDeclSyntax) -> FunctionDeclSyntax {
        guard !method.isOverride else { return method }
        var method = method
        method.modifiers.append(
            DeclModifierSyntax(name: .keyword(.override))
        )
        return method
    }

    private static func removeMutatingModifierIfNeeded(from method: FunctionDeclSyntax) -> FunctionDeclSyntax {
        var method = method
        method.modifiers = method.modifiers.filter { $0.name.tokenKind != .keyword(.mutating) }
        return method
    }

    private static func returningExpression(for method: FunctionDeclSyntax) -> ReturningExpression {
        if let returnType = method.signature.returnClause?.type, returnType != "Void" {
            method.isThrowing ? .throwingStubOutput : .stubOutput
        } else {
            .void
        }
    }

    private static func mockMethodBody(for method: FunctionDeclSyntax, returningExpression: ReturningExpression) -> CodeBlockSyntax {
        CodeBlockSyntax(
            leftBrace: .leftBraceToken(),
            statements: CodeBlockItemListSyntax {
                DeclSyntax("let callTime = Date()")
                returnStatement(for: method, returningExpression: returningExpression)
            },
            rightBrace: .rightBraceToken()
        )
    }

    private static func returnStatement(for method: FunctionDeclSyntax, returningExpression: ReturningExpression) -> ReturnStmtSyntax {
        let leadingTrivia = method.hasParameters ? Trivia.newline : []

        return ReturnStmtSyntax(
            expression: FunctionCallExprSyntax(
                "recordCall",
                rightParen: .rightParenToken().with(\.leadingTrivia, leadingTrivia)
            ) {
                if method.hasParameters {
                    LabeledExprSyntax(label: "with", expression: method.inputParameters)
                        .with(\.leadingTrivia, leadingTrivia)
                        .with(\.trailingComma, .commaToken())
                }

                LabeledExprSyntax(label: "at", expression: DeclReferenceExprSyntax(baseName: .identifier("callTime")))
                    .with(\.leadingTrivia, leadingTrivia)
                    .with(\.trailingComma, .commaToken())

                LabeledExprSyntax(
                    label: "returning",
                    expression: FunctionCallExprSyntax(returningExpression.rawValue) {
                        if returningExpression != .void && method.hasParameters {
                            LabeledExprSyntax(
                                label: "for",
                                colon: .colonToken(),
                                expression: method.inputParameters
                            )
                        }
                    }
                    .wrappedInTry(returningExpression == .throwingStubOutput)
                )
                .with(\.leadingTrivia, leadingTrivia)
            }
        )
    }

}

// MARK: MockMacro.ReturningExpression
private extension MockMacro {

    enum ReturningExpression: String {
        case void = "Void"
        case stubOutput
        case throwingStubOutput
    }

}

private extension FunctionCallExprSyntax {
    /// Abbreviated `FunctionCallExprSyntax` initializer to improve readability.
    init(
        _ calledExpressionText: String,
        leftParen: TokenSyntax = .leftParenToken(),
        rightParen: TokenSyntax = .rightParenToken(),
        @LabeledExprListBuilder argumentsBuilder: () throws -> LabeledExprListSyntax
    ) rethrows {
        self = try FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: .identifier(calledExpressionText)),
            leftParen: leftParen,
            rightParen: rightParen,
            argumentsBuilder: argumentsBuilder
        )
    }
}

//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MockMacro: PeerMacro {

    private static let mockProtocolName = "Mock"

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
                [nsObject, protocolName, mockProtocolName]
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
            inheritanceClause: .emptyClause.appending([className, mockProtocolName]),
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
        mockStructDeclaration.inheritanceClause = (structDeclaration.inheritanceClause ?? .emptyClause).appending([mockProtocolName])

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
        let mockTypes = members.filter { $0.decl.isTypeDeclaration }

        let mockProperties = members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { !$0.isPrivate && !$0.isFinal && !($0.isStatic && shouldOverride) }
            .compactMap { mockProperty(for: $0, shouldAddOverrideModifier: shouldOverride) }

        let mockInits: [InitializerDeclSyntax] = {
            guard forClass, shouldOverride else { return [] }
            return members
                .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
                .filter { !$0.isPrivate }
                .map { mockInitOverride(for: $0) }
        }()

        let mockMethods = members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .filter { !$0.isPrivate && !$0.isFinal && !($0.isStatic && shouldOverride) }
            .compactMap { mockMethod(for: $0, isInClass: forClass, shouldAddOverrideModifier: shouldOverride) }

        return MemberBlockItemListSyntax {
            mockTypes
            DeclSyntax("let blackBox = BlackBox()")
                .with(\.leadingTrivia, .newlines(2))
            DeclSyntax("let stubRegistry = StubRegistry()")
            MemberBlockItemListSyntax {
                for mockProperty in mockProperties {
                    mockProperty
                        .with(\.leadingTrivia, .newlines(2))
                }
            }
            .with(\.leadingTrivia, .newlines(2))
            MemberBlockItemListSyntax {
                for mockInit in mockInits {
                    mockInit
                        .with(\.leadingTrivia, .newlines(2))
                }
            }
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
            "stubValue()"
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

    private static func mockInitOverride(for initializer: InitializerDeclSyntax) -> InitializerDeclSyntax {
        guard let initBody = initializer.body else { return initializer }

        var mockInit = initializer.trimmed

        let superCall = FunctionCallExprSyntax(callee: ExprSyntax("super.init")) {
            for param in mockInit.signature.parameterClause.parameters {
                LabeledExprSyntax(label: param.label, expression: ExprSyntax("\(param.internalName)"))
            }
        }

        let internalParamNames = mockInit.signature.parameterClause.parameters.map { $0.internalName.tokenKind }

        let assignmentStatements = initBody.statements.filter { statement in

            if let infixOperatorStatement = statement.item.as(InfixOperatorExprSyntax.self),
               infixOperatorStatement.operator.is(AssignmentExprSyntax.self),
               let rightOperand = infixOperatorStatement.rightOperand.as(DeclReferenceExprSyntax.self),
               internalParamNames.contains(rightOperand.baseName.tokenKind) {
                return true
            }

            // For some reason in macro expansion tests `self.x = x` is parsed as `InfixOperatorExprSyntax`
            // but when expanding in the compiler it is parsed as a `SequenceExprSyntax` that looks like this:
            // [MemberAccessExprSyntax, AssignmentExprSyntax, DeclReferenceExprSyntax]
            if let sequence = statement.item.as(SequenceExprSyntax.self),
               sequence.elements.count == 3,
               sequence.elements.dropFirst().first?.is(AssignmentExprSyntax.self) == true,
               let paramReference = sequence.elements.last?.as(DeclReferenceExprSyntax.self),
               internalParamNames.contains(paramReference.baseName.tokenKind) {
                return true
            }

            return false
        }

        mockInit.body = CodeBlockSyntax {
            superCall
            for statement in assignmentStatements {
                statement.trimmed
            }
        }

        if !mockInit.isOverride {
            mockInit.modifiers += [DeclModifierSyntax(name: .keyword(.override))]
        }

        return mockInit
    }

    private static func mockMethod(
        for method: FunctionDeclSyntax,
        isInClass: Bool,
        shouldAddOverrideModifier: Bool
    ) -> FunctionDeclSyntax? {
        var mockMethod = method.trimmed

        if isInClass {
            mockMethod.modifiers = mockMethod.modifiers.filter { $0.name.tokenKind != .keyword(.mutating) }
        }

        if shouldAddOverrideModifier && !mockMethod.isOverride {
            mockMethod.modifiers += [DeclModifierSyntax(name: .keyword(.override))]
        }

        mockMethod.body = mockMethodBody(for: mockMethod)

        return mockMethod
    }

    private static func mockMethodBody(for method: FunctionDeclSyntax) -> CodeBlockSyntax {
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

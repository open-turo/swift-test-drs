//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AddMockMacro: PeerMacro {

    private static let mockProtocolName = "Mock"

    private enum TypeBeingMocked: Equatable {
        case `protocol`
        case `class`
        case `struct`
    }

    private struct MockGenerationConfig {
        let typeBeingMocked: TypeBeingMocked
        let isPublic: Bool
        let inheritsFromNSObject: Bool

        var shouldMakeMembersPublic: Bool {
            isPublic && typeBeingMocked == .protocol
        }

        var shouldOverrideMembers: Bool {
            typeBeingMocked == .class
        }

        var isGeneratingClass: Bool {
            typeBeingMocked != .struct
        }

        var shouldGenerateInits: Bool {
            typeBeingMocked != .class
        }

        var needsPublicInit: Bool {
            isPublic && typeBeingMocked != .class
        }

        var shouldMockStaticMembers: Bool {
            typeBeingMocked != .class
        }

        var shouldOverrideInitializers: Bool {
            inheritsFromNSObject
        }

        func shouldMockMember(member: WithModifiersSyntax) -> Bool {
            guard !member.isPrivate else { return false }
            guard !member.isFinal else { return false }
            guard !member.isStatic else { return shouldMockStaticMembers }
            return true
        }
    }

    // MARK: - Expansion

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let mockDeclaration: DeclSyntax

        if let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) {
            guard !(protocolDeclaration.inheritanceClause?.containsActor == true) else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(node),
                        message: AddMockExpansionDiagnostic.actorConstrained
                    )
                )
                return []
            }
            mockDeclaration = DeclSyntax(mockClassDeclaration(from: protocolDeclaration))
        } else if let classDeclaration = declaration.as(ClassDeclSyntax.self) {
            mockDeclaration = DeclSyntax(mockSubclassDeclaration(from: classDeclaration, context: context))
        } else if let structDeclaration = declaration.as(StructDeclSyntax.self) {
            mockDeclaration = DeclSyntax(mockStruct(from: structDeclaration))
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: AddMockExpansionDiagnostic.invalidType
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

    // MARK: - Type Generation

    private static func mockClassDeclaration(from protocolDeclaration: ProtocolDeclSyntax) -> ClassDeclSyntax {
        let protocolName = protocolDeclaration.name.trimmed.text

        // Check if the protocol is marked with @objc, if so, the mock class will need to inherit from NSObject
        let nsObject = protocolDeclaration.attributes.trimmedDescription.contains("@objc") ? "NSObject" : nil

        var classDeclaration = mockClass(
            named: protocolName,
            inheritanceClause: .emptyClause.appending(
                [nsObject, protocolName, mockProtocolName]
                    .compactMap { $0 }
            ),
            members: protocolDeclaration.memberBlock.members,
            config: .init(typeBeingMocked: .protocol, isPublic: protocolDeclaration.isPublic, inheritsFromNSObject: nsObject != nil)
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
        classDeclaration.attributes = protocolDeclaration.attributes.removingAddMockMacro()

        return classDeclaration
    }

    private static func mockSubclassDeclaration(from classDeclaration: ClassDeclSyntax, context: some MacroExpansionContext) -> ClassDeclSyntax {
        if classDeclaration.modifiers.containsKeyword(.final) {
            context.diagnose(
                Diagnostic(
                    node: Syntax(classDeclaration),
                    message: AddMockExpansionDiagnostic.finalClass
                )
            )
        }
        let className = classDeclaration.name.trimmed.text

        let uncheckedSendableAttributeType = classDeclaration.inheritanceClause?.inheritedTypes.first { inheritedType in
            inheritedType.type.as(AttributedTypeSyntax.self)?
                .attributes.first?
                .as(AttributeSyntax.self)?
                .attributeName.as(IdentifierTypeSyntax.self)?
                .name.tokenKind == .identifier("unchecked")
        }

        let inheritanceClause = InheritanceClauseSyntax(inheritedTypes: InheritedTypeListSyntax {
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(className)))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(mockProtocolName)))

            if let uncheckedSendableAttributeType {
                uncheckedSendableAttributeType
            }
        })

        var subclassDeclaration = mockClass(
            named: className,
            inheritanceClause: inheritanceClause,
            members: classDeclaration.memberBlock.members,
            config: .init(typeBeingMocked: .class, isPublic: classDeclaration.isPublic, inheritsFromNSObject: false)
        )

        subclassDeclaration.modifiers += classDeclaration.modifiers
        subclassDeclaration.attributes = classDeclaration.attributes.removingAddMockMacro()

        return subclassDeclaration
    }

    private static func mockStruct(from structDeclaration: StructDeclSyntax) -> StructDeclSyntax {
        var mockStructDeclaration = structDeclaration.trimmed
        mockStructDeclaration.memberBlock.rightBrace.leadingTrivia = []

        mockStructDeclaration.memberBlock.members = mockMembers(
            from: structDeclaration.memberBlock.members,
            config: .init(typeBeingMocked: .struct, isPublic: structDeclaration.isPublic, inheritsFromNSObject: false)
        )
        mockStructDeclaration.name = mockTypeName(from: structDeclaration.name.trimmedDescription)
        mockStructDeclaration.inheritanceClause = (structDeclaration.inheritanceClause ?? .emptyClause).appending([mockProtocolName])

        mockStructDeclaration.modifiers = structDeclaration.modifiers
        mockStructDeclaration.attributes = structDeclaration.attributes.removingAddMockMacro()

        return mockStructDeclaration
    }

    private static func mockClass(
        named typeName: String,
        inheritanceClause: InheritanceClauseSyntax? = nil,
        members: MemberBlockItemListSyntax,
        config: MockGenerationConfig
    ) -> ClassDeclSyntax {
        return ClassDeclSyntax(
            modifiers: DeclModifierListSyntax([.finalModifier]),
            name: mockTypeName(from: typeName),
            inheritanceClause: inheritanceClause
        ) {
            mockMembers(from: members, config: config)
        }
    }

    private static func mockTypeName(from typeName: String) -> TokenSyntax {
        TokenSyntax.identifier("Mock\(typeName)")
    }

    // MARK: - Member Generation

    private static func mockMembers(
        from members: MemberBlockItemListSyntax,
        config: MockGenerationConfig
    ) -> MemberBlockItemListSyntax {
        let mockTypes = members.filter { $0.decl.isTypeDeclaration }
        let mockProperties = mockProperties(from: members, config: config)
        let mockInits = mockInits(from: members, config: config)
        let mockMethods = mockMethods(from: members, config: config)

        return MemberBlockItemListSyntax {
            mockTypes
            VariableDeclSyntax(
                leadingTrivia: .newlines(2),
                modifiers: config.isPublic ? [.publicModifier] : [],
                .let,
                name: "blackBox",
                initializer: InitializerClauseSyntax(
                    value: FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: "BlackBox"))
                )
            )
            VariableDeclSyntax(
                modifiers: config.isPublic ? [.publicModifier] : [],
                .let,
                name: "stubRegistry",
                initializer: InitializerClauseSyntax(
                    value: FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: "StubRegistry"))
                )
            )
            MemberBlockItemListSyntax {
                for mockProperty in mockProperties {
                    mockProperty
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

    private static func mockProperties(
        from members: MemberBlockItemListSyntax,
        config: MockGenerationConfig
    ) -> [VariableDeclSyntax] {
        members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { config.shouldMockMember(member: $0) }
            .compactMap { mockProperty(for: $0, config: config) }
    }

    private static func mockInits(
        from members: MemberBlockItemListSyntax,
        config: MockGenerationConfig
    ) -> [InitializerDeclSyntax] {
        guard config.shouldGenerateInits else { return [] }

        var mockInits = members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
            .filter { !$0.isPrivate }
            .map { mockInit(for: $0, config: config) }

        let emptyInitIsNeeded = !mockInits.isEmpty || config.needsPublicInit
        let alreadyHasEmptyInit = mockInits.contains(where: { $0.signature.parameterClause.parameters.isEmpty })

        if emptyInitIsNeeded && !alreadyHasEmptyInit {
            var emptyInit = InitializerDeclSyntax(
                signature: FunctionSignatureSyntax(parameterClause: FunctionParameterClauseSyntax {}),
                body: CodeBlockSyntax {}
            )
            if config.needsPublicInit {
                emptyInit.modifiers.append(.publicModifier)
            }
            if config.shouldOverrideInitializers {
                emptyInit.modifiers.append(.overrideModifier)
            }
            mockInits.insert(emptyInit, at: 0)
        }

        return mockInits
    }

    private static func mockMethods(
        from members: MemberBlockItemListSyntax,
        config: MockGenerationConfig
    ) -> [FunctionDeclSyntax] {
        members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .filter { config.shouldMockMember(member: $0) }
            .compactMap { mockMethod(for: $0, config: config) }
    }

    private static func mockProperty(
        for property: VariableDeclSyntax,
        config: MockGenerationConfig
    ) -> VariableDeclSyntax {
        var mockProperty = property.trimmed

        if config.shouldMakeMembersPublic && !mockProperty.hasExplicitAccessControl {
            mockProperty.modifiers.append(.publicModifier)
        }

        if config.shouldOverrideMembers && !mockProperty.isOverride {
            mockProperty.modifiers.append(.overrideModifier)
        }

        var attributes = AttributeListSyntax { "@_MockProperty" }
        attributes += mockProperty.attributes
        mockProperty.attributes = attributes

        mockProperty.bindingSpecifier = .keyword(.var)

        mockProperty.bindings = PatternBindingListSyntax {
            for binding in mockProperty.bindings {
                binding
                    .withoutInitializerIfPossible()
                    .with(\.accessorBlock, nil)
            }
        }

        return mockProperty
    }

    private static func mockInit(
        for initializer: InitializerDeclSyntax,
        config: MockGenerationConfig
    ) -> InitializerDeclSyntax {
        var mockInit = initializer.trimmed

        mockInit.body = CodeBlockSyntax {}

        if config.shouldMakeMembersPublic && !mockInit.hasExplicitAccessControl {
            mockInit.modifiers += [.publicModifier]
        }

        if config.shouldOverrideInitializers && !mockInit.isOverride {
            mockInit.modifiers += [.overrideModifier]
        }

        if !mockInit.signature.parameterClause.parameters.isEmpty {
            let deprecatedAttribute = AttributeListSyntax { .deprecated(message: "Use init() instead to initialize a mock") }
            mockInit.attributes += deprecatedAttribute
        }

        return mockInit
    }

    private static func mockMethod(
        for method: FunctionDeclSyntax,
        config: MockGenerationConfig
    ) -> FunctionDeclSyntax? {
        var mockMethod = method.trimmed

        if config.isGeneratingClass {
            mockMethod.modifiers = mockMethod.modifiers.filter { $0.name.tokenKind != .keyword(.mutating) }
        }

        if config.shouldMakeMembersPublic && !mockMethod.hasExplicitAccessControl {
            mockMethod.modifiers += [.publicModifier]
        }

        if config.shouldOverrideMembers && !mockMethod.isOverride {
            mockMethod.modifiers += [.overrideModifier]
        }

        var attributes = AttributeListSyntax { "@_MockFunction" }
        attributes += mockMethod.attributes
        mockMethod.attributes = attributes
        mockMethod.body = nil

        return mockMethod
    }

}

private extension PatternBindingSyntax {
    func withoutInitializerIfPossible() -> PatternBindingSyntax {
        typeAnnotation == nil ? self : with(\.initializer, nil)
    }
}

private extension AttributeListSyntax {
    func removingAddMockMacro() -> AttributeListSyntax {
        filter { $0.trimmedDescription != "@AddMock" }
    }
}

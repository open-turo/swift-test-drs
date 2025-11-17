//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder

/// Defines the kind of test double being generated (Mock or Spy)
enum TestDoubleKind {
    case mock
    case spy

    /// The protocol name this test double conforms to
    var protocolName: String {
        switch self {
        case .mock: return "Mock"
        case .spy: return "Spy"
        }
    }

    /// The name prefix for generated types (e.g., "Mock" in MockUserService)
    var typePrefix: String {
        switch self {
        case .mock: return "Mock"
        case .spy: return "Spy"
        }
    }

    /// Generate the function macro attribute with appropriate parameters
    func functionMacroAttribute(delegateTypeName: String, config: TypeGenerationConfig) -> AttributeSyntax {
        switch self {
        case .mock:
            return AttributeSyntax(stringLiteral: "@_MockFunction")
        case .spy:
            return AttributeSyntax(
                attributeName: IdentifierTypeSyntax(name: .identifier("_SpyFunction")),
                leftParen: .leftParenToken(),
                arguments: .argumentList(LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: StringLiteralExprSyntax(content: delegateTypeName)
                    )
                }),
                rightParen: .rightParenToken()
            )
        }
    }

    /// Generate the property macro attribute with appropriate parameters
    func propertyMacroAttribute(
        for binding: PatternBindingSyntax,
        variable: VariableDeclSyntax,
        delegateTypeName: String,
        config: TypeGenerationConfig
    ) -> AttributeSyntax {
        switch self {
        case .mock:
            return AttributeSyntax(stringLiteral: "@_MockProperty")
        case .spy:
            // Determine if property is get-only or get-set
            let accessorBlock = binding.accessorBlock
            let hasExplicitSetter = accessorBlock?.accessors.as(AccessorDeclListSyntax.self)?.contains {
                $0.accessorSpecifier.tokenKind == .keyword(.set)
            } ?? false

            // Determine if property has a setter based on:
            // 1. If there's an accessor block (protocol/computed property):
            //    - Check if it has a set accessor
            // 2. If no accessor block (stored property):
            //    - Check if it's a var (get-set) or let (get-only)
            let hasSetter: Bool
            if accessorBlock != nil {
                // Protocol property or computed property with explicit accessors
                hasSetter = hasExplicitSetter
            } else {
                // Stored property: var is settable, let is not
                hasSetter = variable.bindingSpecifier.tokenKind == .keyword(.var)
            }

            let accessorType = hasSetter ? "get set" : "get"

            return AttributeSyntax(
                attributeName: IdentifierTypeSyntax(name: .identifier("_SpyProperty")),
                leftParen: .leftParenToken(),
                arguments: .argumentList(LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: StringLiteralExprSyntax(content: accessorType)
                    )
                    LabeledExprSyntax(
                        expression: StringLiteralExprSyntax(content: delegateTypeName)
                    )
                }),
                rightParen: .rightParenToken()
            )
        }
    }

    /// Generate the additional properties needed for this test double kind
    /// (stubRegistry for Mock, real object for Spy)
    func additionalProperties(
        delegateTypeName: String,
        testDoubleName: String,
        isPublic: Bool,
        isStruct: Bool,
        config: TypeGenerationConfig
    ) -> [VariableDeclSyntax] {
        switch self {
        case .mock:
            return [stubRegistryProperty(testDoubleName: testDoubleName, isPublic: isPublic)]
        case .spy:
            // Class spies are subclasses - they don't wrap a real instance
            guard config.typeBeingMocked != .class else { return [] }
            // Protocol and struct spies wrap a real instance
            return [realProperty(delegateTypeName: delegateTypeName, isStruct: isStruct, config: config)]
        }
    }

    /// Generate the initializers for this test double kind
    func initializers(
        delegateTypeName: String,
        originalMembers: MemberBlockItemListSyntax,
        config: TypeGenerationConfig
    ) -> [InitializerDeclSyntax] {
        switch self {
        case .mock:
            return mockInitializers(originalMembers: originalMembers, config: config)
        case .spy:
            // Class spies are subclasses - use parent initializers like mocks do
            if config.typeBeingMocked == .class {
                return mockInitializers(originalMembers: originalMembers, config: config)
            }
            // Protocol and struct spies wrap a real instance
            return [spyInitializer(delegateTypeName: delegateTypeName, config: config)]
        }
    }

    // MARK: - Mock-specific Helpers

    private func stubRegistryProperty(testDoubleName: String, isPublic: Bool) -> VariableDeclSyntax {
        VariableDeclSyntax(
            modifiers: isPublic ? [.publicModifier] : [],
            .let,
            name: "stubRegistry",
            initializer: InitializerClauseSyntax(
                value: FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: "StubRegistry")) {
                    LabeledExprSyntax(
                        label: "mockType",
                        expression: MemberAccessExprSyntax(
                            base: ExprSyntax(stringLiteral: testDoubleName),
                            period: .periodToken(),
                            declName: DeclReferenceExprSyntax(baseName: .keyword(.self))
                        )
                    )
                }
            )
        )
    }

    private func mockInitializers(
        originalMembers: MemberBlockItemListSyntax,
        config: TypeGenerationConfig
    ) -> [InitializerDeclSyntax] {
        guard config.shouldGenerateInits else { return [] }

        var mockInits = originalMembers
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
            if config.shouldOverrideInitializer(emptyInit) {
                emptyInit.modifiers.append(.overrideModifier)
            }
            mockInits.insert(emptyInit, at: 0)
        }

        return mockInits
    }

    private func mockInit(
        for initializer: InitializerDeclSyntax,
        config: TypeGenerationConfig
    ) -> InitializerDeclSyntax {
        var mockInit = initializer.trimmed

        mockInit.body = CodeBlockSyntax {}

        if config.shouldMakeMembersPublic && !mockInit.hasExplicitAccessControl {
            mockInit.modifiers += [.publicModifier]
        }

        if config.shouldOverrideInitializer(initializer) && !mockInit.isOverride {
            mockInit.modifiers += [.overrideModifier]
        }

        if !mockInit.signature.parameterClause.parameters.isEmpty {
            let deprecatedAttribute = AttributeListSyntax { .deprecated(message: "Use init() instead to initialize a mock") }
            mockInit.attributes += deprecatedAttribute
        }

        return mockInit
    }

    // MARK: - Spy-specific Helpers

    private func realProperty(delegateTypeName: String, isStruct: Bool, config: TypeGenerationConfig) -> VariableDeclSyntax {
        return VariableDeclSyntax(
            modifiers: [.privateModifier],
            isStruct ? .var : .let,
            name: "real",
            type: TypeAnnotationSyntax(
                type: IdentifierTypeSyntax(name: .identifier(delegateTypeName))
            )
        )
    }

    private func spyInitializer(
        delegateTypeName: String,
        config: TypeGenerationConfig
    ) -> InitializerDeclSyntax {
        var spyInit = InitializerDeclSyntax(
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    FunctionParameterSyntax(
                        firstName: .identifier("real"),
                        type: IdentifierTypeSyntax(name: .identifier(delegateTypeName))
                    )
                }
            )
        ) {
            ExprSyntax(stringLiteral: "self.real = real")
        }

        if config.needsPublicInit {
            spyInit.modifiers.append(.publicModifier)
        }

        return spyInit
    }
}

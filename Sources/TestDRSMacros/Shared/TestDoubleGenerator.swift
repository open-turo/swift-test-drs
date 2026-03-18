//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Generates test doubles (mocks or spies) from protocol/class/struct declarations
struct TestDoubleGenerator {
    let kind: TestDoubleKind

    // MARK: - Main Entry Point

    func generate(
        from node: AttributeSyntax,
        attachedTo declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let testDoubleDeclaration: DeclSyntax

        if let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) {
            guard !(protocolDeclaration.inheritanceClause?.containsActor == true) else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(node),
                        message: kind == .mock ? AddMockExpansionDiagnostic.actorConstrained : AddSpyExpansionDiagnostic.actorConstrained
                    )
                )
                return []
            }
            testDoubleDeclaration = DeclSyntax(classFromProtocol(protocolDeclaration))
        } else if let classDeclaration = declaration.as(ClassDeclSyntax.self) {
            testDoubleDeclaration = DeclSyntax(subclassFromClass(classDeclaration, context: context))
        } else if let structDeclaration = declaration.as(StructDeclSyntax.self) {
            testDoubleDeclaration = DeclSyntax(structFromStruct(structDeclaration))
        } else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: kind == .mock ? AddMockExpansionDiagnostic.invalidType : AddSpyExpansionDiagnostic.invalidType
                )
            )
            return []
        }

        return [
            DeclSyntax(
                try IfConfigDeclSyntax.ifDebug {
                    testDoubleDeclaration
                        .with(\.leadingTrivia, .newlines(2))
                        .with(\.trailingTrivia, .newlines(2))
                }
            )
        ]
    }

    // MARK: - Type Generation

    /// Builds the generic parameter clause for a protocol spy, including RealType and associated types
    private func buildGenericParameterClause(
        for protocolDeclaration: ProtocolDeclSyntax,
        protocolName: String
    ) -> GenericParameterClauseSyntax? {
        var genericParameters: [GenericParameterSyntax] = []

        // For spies, add RealType parameter
        if kind == .spy {
            genericParameters.append(
                GenericParameterSyntax(
                    name: .identifier("RealType"),
                    colon: .colonToken(),
                    inheritedType: IdentifierTypeSyntax(name: .identifier(protocolName)),
                    trailingComma: protocolDeclaration.primaryAssociatedTypeClause != nil ? .commaToken() : nil
                )
            )
        }

        // Add associated type parameters if present
        if let associatedTypeClause = protocolDeclaration.primaryAssociatedTypeClause {
            for (index, associatedType) in associatedTypeClause.primaryAssociatedTypes.enumerated() {
                let isLast = index == associatedTypeClause.primaryAssociatedTypes.count - 1
                genericParameters.append(
                    GenericParameterSyntax(
                        name: associatedType.name,
                        trailingComma: isLast ? nil : .commaToken()
                    )
                )
            }
        }

        // TODO: Issue #85 - Support protocols with associated types and where clauses
        // Currently, protocols with where clauses on associated types (e.g., `where Entity: Identifiable`)
        // will generate spies that fail to compile due to type mismatches between Entity and RealType.Entity.
        // To fix this, we need to:
        // 1. Extract where clause constraints from the protocol
        // 2. Add explicit associated type parameters to the generic parameter list
        // 3. Add where clause constraints that bind RealType.AssocType == AssocType
        // 4. Forward all other where clause constraints
        // Example: protocol Repository<Entity> where Entity: Identifiable, Entity.ID == Int
        // Should generate: class SpyRepository<RealType, Entity>: Repository
        //                    where RealType: Repository, RealType.Entity == Entity,
        //                          Entity: Identifiable, Entity.ID == Int

        // Create generic parameter clause if we have any parameters
        guard !genericParameters.isEmpty else { return nil }

        return GenericParameterClauseSyntax(
            leftAngle: .leftAngleToken(),
            parameters: GenericParameterListSyntax(genericParameters),
            rightAngle: .rightAngleToken()
        )
    }

    private func classFromProtocol(_ protocolDeclaration: ProtocolDeclSyntax) -> ClassDeclSyntax {
        let protocolName = protocolDeclaration.name.trimmed.text

        // Check if the protocol is marked with @objc, if so, the class will need to inherit from NSObject
        let nsObject = protocolDeclaration.attributes.trimmedDescription.contains("@objc") ? "NSObject" : nil

        let genericParameterClause = buildGenericParameterClause(for: protocolDeclaration, protocolName: protocolName)

        var classDeclaration = generateClass(
            named: protocolName,
            inheritanceClause: .emptyClause.appending(
                [nsObject, protocolName, kind.protocolName]
                    .compactMap { $0 }
            ),
            genericParameterClause: genericParameterClause,
            members: protocolDeclaration.memberBlock.members,
            config: TypeGenerationConfig(
                typeBeingMocked: .protocol,
                originalTypeName: protocolName,
                isPublic: protocolDeclaration.isPublic,
                inheritsFromNSObject: nsObject != nil
            )
        )

        classDeclaration.modifiers += protocolDeclaration.modifiers
        classDeclaration.attributes = protocolDeclaration.attributes.removingTestDoubleMacros()

        return classDeclaration
    }

    private func subclassFromClass(_ classDeclaration: ClassDeclSyntax, context: some MacroExpansionContext) -> ClassDeclSyntax {
        if classDeclaration.modifiers.containsKeyword(.final) {
            context.diagnose(
                Diagnostic(
                    node: Syntax(classDeclaration),
                    message: kind == .mock ? AddMockExpansionDiagnostic.finalClass : AddSpyExpansionDiagnostic.finalClass
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
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(kind.protocolName)))

            if let uncheckedSendableAttributeType {
                uncheckedSendableAttributeType
            }
        })

        var subclassDeclaration = generateClass(
            named: className,
            inheritanceClause: inheritanceClause,
            members: classDeclaration.memberBlock.members,
            config: TypeGenerationConfig(
                typeBeingMocked: .class,
                originalTypeName: className,
                isPublic: classDeclaration.isPublic,
                inheritsFromNSObject: false
            )
        )

        subclassDeclaration.modifiers += classDeclaration.modifiers
        subclassDeclaration.attributes = classDeclaration.attributes.removingTestDoubleMacros()

        return subclassDeclaration
    }

    private func structFromStruct(_ structDeclaration: StructDeclSyntax) -> StructDeclSyntax {
        var testDoubleStruct = structDeclaration.trimmed
        testDoubleStruct.memberBlock.rightBrace.leadingTrivia = []

        let structName = structDeclaration.name.trimmedDescription
        let testDoubleName = "\(kind.typePrefix)\(structName)"

        testDoubleStruct.memberBlock.members = generateMembers(
            from: structDeclaration.memberBlock.members,
            config: TypeGenerationConfig(
                typeBeingMocked: .struct,
                originalTypeName: structName,
                isPublic: structDeclaration.isPublic,
                inheritsFromNSObject: false
            ),
            testDoubleName: testDoubleName
        )
        testDoubleStruct.name = testDoubleTypeName(from: structName)
        testDoubleStruct.inheritanceClause = (structDeclaration.inheritanceClause ?? .emptyClause)
            .appending([kind.protocolName])

        // No generic parameters needed for struct spies - they delegate to the concrete struct type

        testDoubleStruct.modifiers = structDeclaration.modifiers
        testDoubleStruct.attributes = structDeclaration.attributes.removingTestDoubleMacros()

        return testDoubleStruct
    }

    private func generateClass(
        named typeName: String,
        inheritanceClause: InheritanceClauseSyntax? = nil,
        genericParameterClause: GenericParameterClauseSyntax? = nil,
        members: MemberBlockItemListSyntax,
        config: TypeGenerationConfig
    ) -> ClassDeclSyntax {
        let testDoubleName = "\(kind.typePrefix)\(typeName)"
        return ClassDeclSyntax(
            modifiers: DeclModifierListSyntax([.finalModifier]),
            name: testDoubleTypeName(from: typeName),
            genericParameterClause: genericParameterClause,
            inheritanceClause: inheritanceClause
        ) {
            generateMembers(
                from: members,
                config: config,
                testDoubleName: testDoubleName
            )
        }
    }

    private func testDoubleTypeName(from typeName: String) -> TokenSyntax {
        TokenSyntax.identifier("\(kind.typePrefix)\(typeName)")
    }

    // MARK: - Member Generation

    private func generateMembers(
        from members: MemberBlockItemListSyntax,
        config: TypeGenerationConfig,
        testDoubleName: String
    ) -> MemberBlockItemListSyntax {
        let types = members.filter { $0.decl.isTypeDeclaration }
        let properties = transformProperties(from: members, config: config)
        let inits = kind.initializers(
            delegateTypeName: config.delegateTypeName,
            originalMembers: members,
            config: config
        )
        let methods = transformMethods(from: members, config: config)

        return MemberBlockItemListSyntax {
            types
            blackBoxProperty(testDoubleName: testDoubleName, isPublic: config.isPublic)
            MemberBlockItemListSyntax {
                for additionalProperty in kind.additionalProperties(
                    delegateTypeName: config.delegateTypeName,
                    testDoubleName: testDoubleName,
                    isPublic: config.isPublic,
                    isStruct: config.typeBeingMocked == .struct,
                    config: config
                ) {
                    MemberBlockItemSyntax(decl: additionalProperty)
                }
            }
            MemberBlockItemListSyntax {
                for property in properties {
                    property
                }
            }
            .with(\.leadingTrivia, .newlines(2))
            MemberBlockItemListSyntax {
                for initializer in inits {
                    MemberBlockItemSyntax(decl: initializer)
                        .with(\.leadingTrivia, .newlines(2))
                }
            }
            MemberBlockItemListSyntax {
                for method in methods {
                    method
                        .with(\.leadingTrivia, .newlines(2))
                }
            }
            .with(\.trailingTrivia, Trivia(pieces: [.newlines(1), .spaces(1)]))
        }
    }

    private func blackBoxProperty(testDoubleName: String, isPublic: Bool) -> VariableDeclSyntax {
        VariableDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: isPublic ? [.publicModifier] : [],
            .let,
            name: "blackBox",
            initializer: InitializerClauseSyntax(
                value: FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: "BlackBox")) {
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

    private func transformProperties(
        from members: MemberBlockItemListSyntax,
        config: TypeGenerationConfig
    ) -> [MemberBlockItemSyntax] {
        members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { config.shouldMockMember(member: $0) }
            .compactMap { transformProperty($0, config: config) }
            .map { MemberBlockItemSyntax(decl: $0) }
    }

    private func transformMethods(
        from members: MemberBlockItemListSyntax,
        config: TypeGenerationConfig
    ) -> [MemberBlockItemSyntax] {
        members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .filter { config.shouldMockMember(member: $0) }
            .compactMap { transformMethod($0, config: config) }
            .map { MemberBlockItemSyntax(decl: $0) }
    }

    private func transformProperty(
        _ property: VariableDeclSyntax,
        config: TypeGenerationConfig
    ) -> VariableDeclSyntax {
        var transformedProperty = property.trimmed

        if config.shouldMakeMembersPublic && !transformedProperty.hasExplicitAccessControl {
            transformedProperty.modifiers.append(.publicModifier)
        }

        if config.shouldOverrideMembers && !transformedProperty.isOverride {
            transformedProperty.modifiers.append(.overrideModifier)
        }

        // Apply the appropriate property macro attribute
        // For spies, the macro needs to know if it's "get" or "get set"
        // Use the ORIGINAL property to determine get/set, not the transformed one
        if let firstBinding = transformedProperty.bindings.first {
            var attributes = AttributeListSyntax {
                kind.propertyMacroAttribute(
                    for: firstBinding,
                    variable: property,
                    delegateTypeName: config.delegateTypeName,
                    config: config
                )
            }
            attributes += transformedProperty.attributes
            transformedProperty.attributes = attributes
        }

        transformedProperty.bindingSpecifier = .keyword(.var)

        transformedProperty.bindings = PatternBindingListSyntax {
            for binding in transformedProperty.bindings {
                binding
                    .withoutInitializerIfPossible()
                    .with(\.accessorBlock, nil)
            }
        }

        return transformedProperty
    }

    private func transformMethod(
        _ method: FunctionDeclSyntax,
        config: TypeGenerationConfig
    ) -> FunctionDeclSyntax? {
        var transformedMethod = method.trimmed

        if config.isGeneratingClass {
            transformedMethod.modifiers = transformedMethod.modifiers.filter { $0.name.tokenKind != .keyword(.mutating) }
        }

        if config.shouldMakeMembersPublic && !transformedMethod.hasExplicitAccessControl {
            transformedMethod.modifiers += [.publicModifier]
        }

        if config.shouldOverrideMembers && !transformedMethod.isOverride {
            transformedMethod.modifiers += [.overrideModifier]
        }

        var attributes = AttributeListSyntax {
            kind.functionMacroAttribute(delegateTypeName: config.delegateTypeName, config: config)
        }
        attributes += transformedMethod.attributes
        transformedMethod.attributes = attributes
        transformedMethod.body = nil

        return transformedMethod
    }
}

// MARK: - Syntax Extensions

private extension PatternBindingSyntax {
    func withoutInitializerIfPossible() -> PatternBindingSyntax {
        typeAnnotation == nil ? self : with(\.initializer, nil)
    }
}

private extension AttributeListSyntax {
    func removingTestDoubleMacros() -> AttributeListSyntax {
        filter { attribute in
            let trimmed = attribute.trimmedDescription
            return trimmed != "@AddMock" && trimmed != "@AddSpy"
        }
    }
}

//
// Created on 6/20/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MockMacro: ExtensionMacro, MemberMacro, MemberAttributeMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard declarationTypeIsSupported(declaration) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: MockExpansionDiagnostic.invalidType
                )
            )
            return []
        }

        let inheritedType = InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "Mock"))
        let typeList = InheritedTypeListSyntax(arrayLiteral: inheritedType)
        let inheritanceClause = InheritanceClauseSyntax(inheritedTypes: typeList)

        return [
            ExtensionDeclSyntax(extendedType: type, inheritanceClause: inheritanceClause) {}
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard declarationTypeIsSupported(declaration) else { return [] }

        if let variable = member.as(VariableDeclSyntax.self) {
            guard variable.bindings.allSatisfy({ $0.initializer == nil }) else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(variable),
                        message: MockExpansionDiagnostic.propertyWithInitializer
                    )
                )
                return []
            }
            return ["@_MockProperty"]
        } else if let function = member.as(FunctionDeclSyntax.self) {
            guard function.body == nil else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(function),
                        message: MockExpansionDiagnostic.functionWithBody
                    )
                )
                return []
            }
            return ["@_MockFunction"]
        }

        return []
    }

    public static func expansion(
        of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let declIsPublic: Bool

        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            declIsPublic = classDecl.isPublic
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            declIsPublic = structDecl.isPublic
        } else {
            // Unsupported type
            return []
        }

        return [
            DeclSyntax(
                VariableDeclSyntax(
                    modifiers: declIsPublic ? [.publicModifier] : [],
                    .let,
                    name: "blackBox",
                    initializer: InitializerClauseSyntax(
                        value: FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: "BlackBox"))
                    )
                )
            ),
            DeclSyntax(
                VariableDeclSyntax(
                    modifiers: declIsPublic ? [.publicModifier] : [],
                    .let,
                    name: "stubRegistry",
                    initializer: InitializerClauseSyntax(
                        value: FunctionCallExprSyntax(callee: ExprSyntax(stringLiteral: "StubRegistry"))
                    )
                )
            )
        ]
    }

    private static func declarationTypeIsSupported(_ declaration: some DeclGroupSyntax) -> Bool {
        declaration.is(ClassDeclSyntax.self) || declaration.is(StructDeclSyntax.self)
    }

}

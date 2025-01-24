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
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
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
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {
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

    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard declarationTypeIsSupported(declaration) else { return [] }

        return ["let blackBox = BlackBox()", "let stubRegistry = StubRegistry()"]
    }

    private static func declarationTypeIsSupported(_ declaration: some DeclGroupSyntax) -> Bool {
        declaration.is(ClassDeclSyntax.self) || declaration.is(StructDeclSyntax.self)
    }

}

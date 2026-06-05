//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SpyPropertyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: SpyPropertyExpansionDiagnostic.invalidType
                )
            )
            return []
        }

        guard variable.bindingSpecifier.tokenKind == .keyword(.var) else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: SpyPropertyExpansionDiagnostic.immutable
                )
            )
            return []
        }

        guard variable.bindings.allSatisfy({ $0.accessorBlock == nil }) else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: SpyPropertyExpansionDiagnostic.existingAccessor
                )
            )
            return []
        }

        guard let propertyName = variable.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            return []
        }

        // Extract arguments: first is accessor type, second is delegate type name
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let accessorType = arguments.first?.expression
              .as(StringLiteralExprSyntax.self)?
              .segments.first?.as(StringSegmentSyntax.self)?
              .content.text,
              let delegateTypeName = arguments.dropFirst().first?.expression
              .as(StringLiteralExprSyntax.self)?
              .segments.first?.as(StringSegmentSyntax.self)?
              .content.text else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: SpyPropertyExpansionDiagnostic.missingArguments
                )
            )
            return []
        }

        let hasSetter = accessorType.contains("set")

        let isClassMember = variable.isClassMember
        let isStaticMember = variable.isStatic && !isClassMember
        let isOverride = variable.isOverride

        let targetPrefix = spyDelegationTarget(
            isOverride: isOverride,
            isClassMember: isClassMember,
            isStaticMember: isStaticMember,
            delegateTypeName: delegateTypeName
        )

        var result: [AccessorDeclSyntax] = []

        // Always generate getter
        result.append(
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                "\(raw: targetPrefix).\(raw: propertyName)"
            }
        )

        // Generate setter if needed
        if hasSetter {
            result.append(
                AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                    "\(raw: targetPrefix).\(raw: propertyName) = newValue"
                }
            )
        }

        return result
    }
}

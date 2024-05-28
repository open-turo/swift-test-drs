//
// Created on 5/27/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MockPropertyMacro: AccessorMacro {
    public static func expansion(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: MockPropertyExpansionDiagnostic.invalidType
                )
            )
            return []
        }

        guard variable.bindingSpecifier.tokenKind == .keyword(.var) else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: MockPropertyExpansionDiagnostic.immutable
                )
            )
            return []
        }

        guard variable.bindings.allSatisfy({ $0.accessorBlock == nil }) else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: MockPropertyExpansionDiagnostic.existingAccessor
                )
            )
            return []
        }

        return [
            AccessorDeclSyntax(accessorSpecifier: .keyword(.get)) {
                "stubOutput()"
            },
            AccessorDeclSyntax(accessorSpecifier: .keyword(.set)) {
                "setStub(value: newValue)"
            }
        ]
    }
}

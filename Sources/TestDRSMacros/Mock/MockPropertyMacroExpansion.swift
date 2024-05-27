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

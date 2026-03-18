//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct AddSpyMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let generator = TestDoubleGenerator(kind: .spy)
        return try generator.generate(from: node, attachedTo: declaration, in: context)
    }
}

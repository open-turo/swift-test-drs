//
// Created on 5/24/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct InvariantMacro: ExpressionMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let invariant = node.arguments.first!.expression

        return """
        withObservationTracking {
            assert(\(invariant))
        } onChange: { [weak self] in
            guard let self else { return }
            assert(\(invariant))
        }
        """
    }

}

//
// Created on 3/6/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension AttributeSyntax {
    static func deprecated(message: String) -> AttributeSyntax {
        AttributeSyntax(
            atSign: .atSignToken(),
            attributeName: IdentifierTypeSyntax(name: .identifier("available")),
            leftParen: .leftParenToken(),
            arguments: AttributeSyntax.Arguments(
                LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(baseName: .identifier("*"))
                    )
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(baseName: .keyword(.deprecated))
                    )
                    LabeledExprSyntax(
                        label: "message",
                        expression: StringLiteralExprSyntax(content: message)
                    )
                }
            ),
            rightParen: .rightParenToken()
        )
    }
}

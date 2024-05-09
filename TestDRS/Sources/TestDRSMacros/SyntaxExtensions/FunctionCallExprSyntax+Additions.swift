//
// Created on 5/3/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension FunctionCallExprSyntax {

    func wrappedInTry(_ shouldWrap: Bool) -> ExprSyntax {
        shouldWrap ? ExprSyntax(TryExprSyntax(expression: self)) : ExprSyntax(self)
    }

    var memberAccessWithoutBaseName: MemberAccessExprSyntax? {
        if var memberAccess = calledExpression.as(MemberAccessExprSyntax.self) {
            memberAccess.declName.baseName = ""
            return memberAccess
        }
        return nil
    }

    var signature: String {
        let argumentLabels = arguments.map { argument in
            "\(argument.label ?? "_"):"
        }.joined()

        return "\(baseName ?? "")(\(argumentLabels))"
    }

    private var baseName: TokenSyntax? {
        if let memberAccess = calledExpression.as(MemberAccessExprSyntax.self) {
            return memberAccess.declName.baseName
        } else if let reference = calledExpression.as(DeclReferenceExprSyntax.self) {
            return reference.baseName
        }
        return nil
    }

}

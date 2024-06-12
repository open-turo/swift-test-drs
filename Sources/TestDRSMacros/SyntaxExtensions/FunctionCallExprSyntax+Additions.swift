//
// Created on 5/3/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension FunctionCallExprSyntax {
    func wrappedInTry(_ shouldWrap: Bool) -> ExprSyntax {
        shouldWrap ? ExprSyntax(TryExprSyntax(expression: self)) : ExprSyntax(self)
    }
}

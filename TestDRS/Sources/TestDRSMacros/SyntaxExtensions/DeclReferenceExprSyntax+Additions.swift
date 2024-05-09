//
// Created on 5/9/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension DeclReferenceExprSyntax {
    func withArguments() -> DeclReferenceExprSyntax {
        guard argumentNames == nil else { return self }
        var copy = self
        copy.argumentNames = DeclNameArgumentsSyntax(arguments: .init())
        return copy
    }
}

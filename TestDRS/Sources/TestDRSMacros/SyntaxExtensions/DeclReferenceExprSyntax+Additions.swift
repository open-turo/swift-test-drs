//
// Created on 5/21/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension DeclReferenceExprSyntax {
    func withArguments() -> DeclReferenceExprSyntax {
        guard argumentNames == nil else { return self }
        return with(\.argumentNames, DeclNameArgumentsSyntax(arguments: .init()))
    }
}

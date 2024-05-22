//
// Created on 5/2/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension FunctionParameterSyntax {
    var internalName: TokenSyntax {
        secondName ?? firstName
    }

    var label: String? {
        guard firstName.tokenKind != .wildcard else { return nil }
        return firstName.text
    }
}

//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension PatternBindingSyntax {

    func withoutInitializer() -> PatternBindingSyntax {
        var copy = self
        copy.initializer = nil
        return copy
    }

    func withAccessorBlock(_ accessorBlock: AccessorBlockSyntax?) -> PatternBindingSyntax {
        var copy = self
        copy.accessorBlock = accessorBlock
        return copy
    }

}

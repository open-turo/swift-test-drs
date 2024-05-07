//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension WithModifiersSyntax {

    var isOverride: Bool {
        modifiers.containsKeyword(.override)
    }

    var isPrivate: Bool {
        modifiers.containsKeyword(.private)
    }

    var isStatic: Bool {
        modifiers.containsKeyword(.static)
    }

    var isClassMember: Bool {
        modifiers.containsKeyword(.class)
    }

}

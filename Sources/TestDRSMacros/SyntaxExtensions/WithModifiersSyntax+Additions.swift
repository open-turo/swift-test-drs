//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension WithModifiersSyntax {

    var isOverride: Bool {
        modifiers.containsKeyword(.override)
    }

    var isPublic: Bool {
        modifiers.containsKeyword(.public)
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

    var isFinal: Bool {
        modifiers.containsKeyword(.final)
    }

    var hasExplicitAccessControl: Bool {
        modifiers.containsKeyword(.private) || modifiers.containsKeyword(.fileprivate) || modifiers.containsKeyword(.internal) || modifiers.containsKeyword(.public)
    }

}

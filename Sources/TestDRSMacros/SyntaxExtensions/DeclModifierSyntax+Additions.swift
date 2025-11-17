//
// Created on 3/6/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension DeclModifierSyntax {
    static let publicModifier = DeclModifierSyntax(name: .keyword(.public))
    static let overrideModifier = DeclModifierSyntax(name: .keyword(.override))
    static let finalModifier = DeclModifierSyntax(name: .keyword(.final))
    static let privateModifier = DeclModifierSyntax(name: .keyword(.private))
}

//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct ExpectationMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ExpectWasCalledMacro.self,
        ExpectWasNotCalledMacro.self,
    ]
}

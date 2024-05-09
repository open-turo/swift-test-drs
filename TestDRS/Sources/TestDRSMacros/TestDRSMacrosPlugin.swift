//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct TestDRSMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MockMacro.self,
        SetStubReturningOutputMacro.self,
        SetStubThrowingErrorMacro.self,
        SetStubUsingClosureMacro.self
    ]
}

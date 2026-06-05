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
        AddMockMacro.self,
        AddSpyMacro.self,
        MockMacro.self,
        MockFunctionMacro.self,
        MockPropertyMacro.self,
        SpyFunctionMacro.self,
        SpyPropertyMacro.self,
        SetStubReturningOutputMacro.self,
        SetStubThrowingErrorMacro.self,
        SetStubUsingClosureMacro.self,
        ExpectWasCalledMacro.self,
        ExpectWasNotCalledMacro.self,
        ConfirmationOfCallMacro.self,
        ExpectCaseMacro.self
    ]
}

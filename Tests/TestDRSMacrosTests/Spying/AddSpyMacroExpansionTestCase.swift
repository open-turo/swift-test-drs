//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

class AddSpyMacroExpansionTestCase: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["AddSpy": AddSpyMacro.self, "_SpyProperty": SpyPropertyMacro.self, "_SpyFunction": SpyFunctionMacro.self]) {
            super.invokeTest()
        }
    }

}

#endif

//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

class AddMockMacroExpansionTestCase: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["AddMock": AddMockMacro.self, "_MockProperty": MockPropertyMacro.self, "_MockFunction": MockFunctionMacro.self]) {
            super.invokeTest()
        }
    }

}

#endif

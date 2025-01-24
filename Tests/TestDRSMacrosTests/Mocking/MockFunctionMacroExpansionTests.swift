//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class MockFunctionMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["_MockFunction": MockFunctionMacro.self]) {
            super.invokeTest()
        }
    }

    func testFunction_TakingVoid_ReturningVoid() {
        assertMacro {
            """
            @_MockFunction
            func foo()
            """
        } expansion: {
            """
            func foo() {
                recordCall()
                return stubOutput()
            }
            """
        }
    }

    func testFunction_TakingVoid_ReturningInt() {
        assertMacro {
            """
            @_MockFunction
            func foo() -> Int
            """
        } expansion: {
            """
            func foo() -> Int {
                recordCall(returning: Int.self)
                return stubOutput()
            }
            """
        }
    }

    func testFunction_TakingString_ReturningInt() {
        assertMacro {
            """
            @_MockFunction
            func foo(paramOne: String) -> Int
            """
        } expansion: {
            """
            func foo(paramOne: String) -> Int {
                recordCall(with: paramOne, returning: Int.self)
                return stubOutput(for: paramOne)
            }
            """
        }
    }

    func testFunction_TakingMultipleParameters_ReturningInt() {
        assertMacro {
            """
            @_MockFunction
            func foo(paramOne: Int, paramTwo: String, paramThree: bool) -> Int
            """
        } expansion: {
            """
            func foo(paramOne: Int, paramTwo: String, paramThree: bool) -> Int {
                recordCall(with: (paramOne, paramTwo, paramThree), returning: Int.self)
                return stubOutput(for: (paramOne, paramTwo, paramThree))
            }
            """
        }
    }

    func testThrowingFunction_TakingVoid_ReturningInt() {
        assertMacro {
            """
            @_MockFunction
            func foo() throws -> Int
            """
        } expansion: {
            """
            func foo() throws -> Int {
                recordCall(returning: Int.self)
                return try throwingStubOutput()
            }
            """
        }
    }

    func testAsyncThrowingFunction_TakingInt_ReturningBlock() {
        assertMacro {
            """
            @_MockFunction
            func foo(paramOne: Int) async throws -> (() -> Void)
            """
        } expansion: {
            """
            func foo(paramOne: Int) async throws -> (() -> Void) {
                recordCall(with: paramOne, returning: (() -> Void).self)
                return try throwingStubOutput(for: paramOne)
            }
            """
        }
    }

}

#endif

//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class SpyFunctionMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["_SpyFunction": SpyFunctionMacro.self]) {
            super.invokeTest()
        }
    }

    func testFunction_TakingVoid_ReturningVoid() {
        assertMacro {
            """
            @_SpyFunction("RealType")
            func foo()
            """
        } expansion: {
            """
            func foo() {
                recordCall()
                real.foo()
            }
            """
        }
    }

    func testFunction_TakingVoid_ReturningInt() {
        assertMacro {
            """
            @_SpyFunction("RealType")
            func foo() -> Int
            """
        } expansion: {
            """
            func foo() -> Int {
                recordCall(returning: Int.self)
                return real.foo()
            }
            """
        }
    }

    func testFunction_TakingString_ReturningInt() {
        assertMacro {
            """
            @_SpyFunction("RealType")
            func foo(paramOne: String) -> Int
            """
        } expansion: {
            """
            func foo(paramOne: String) -> Int {
                recordCall(with: paramOne, returning: Int.self)
                return real.foo(paramOne: paramOne)
            }
            """
        }
    }

    func testFunction_TakingMultipleParameters_ReturningInt() {
        assertMacro {
            """
            @_SpyFunction("RealType")
            func foo(paramOne: Int, paramTwo: String, paramThree: Bool) -> Int
            """
        } expansion: {
            """
            func foo(paramOne: Int, paramTwo: String, paramThree: Bool) -> Int {
                recordCall(with: (paramOne, paramTwo, paramThree), returning: Int.self)
                return real.foo(paramOne: paramOne, paramTwo: paramTwo, paramThree: paramThree)
            }
            """
        }
    }

    func testThrowingFunction_TakingVoid_ReturningInt() {
        assertMacro {
            """
            @_SpyFunction("RealType")
            func foo() throws -> Int
            """
        } expansion: {
            """
            func foo() throws -> Int {
                recordCall(returning: Int.self)
                return try real.foo()
            }
            """
        }
    }

    func testAsyncThrowingFunction_TakingInt_ReturningBlock() {
        assertMacro {
            """
            @_SpyFunction("RealType")
            func foo(paramOne: Int) async throws -> (() -> Void)
            """
        } expansion: {
            """
            func foo(paramOne: Int) async throws -> (() -> Void) {
                recordCall(with: paramOne, returning: (() -> Void).self)
                return try await real.foo(paramOne: paramOne)
            }
            """
        }
    }

    func testStaticFunction() {
        assertMacro {
            """
            @_SpyFunction("RealType")
            static func foo()
            """
        } expansion: {
            """
            static func foo() {
                recordCall()
                RealType.foo()
            }
            """
        }
    }

    func testClassFunction() {
        assertMacro {
            """
            @_SpyFunction("RealType")
            override class func foo()
            """
        } expansion: {
            """
            override class func foo() {
                recordCall()
                super.foo()
            }
            """
        }
    }

}

#endif

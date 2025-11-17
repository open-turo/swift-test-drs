//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class SpyPropertyMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["_SpyProperty": SpyPropertyMacro.self]) {
            super.invokeTest()
        }
    }

    func testPropertyGetAccessor() {
        assertMacro {
            """
            @_SpyProperty("get", "RealType")
            var foo: String
            """
        } expansion: {
            """
            var foo: String {
                get {
                    real.foo
                }
            }
            """
        }
    }

    func testPropertyGetSetAccessor() {
        assertMacro {
            """
            @_SpyProperty("get set", "RealType")
            var foo: String
            """
        } expansion: {
            """
            var foo: String {
                get {
                    real.foo
                }
                set {
                    real.foo = newValue
                }
            }
            """
        }
    }

    func testPropertyWithExistingAccessorDiagnostic() {
        assertMacro {
            """
            @_SpyProperty("get", "RealType")
            var foo: String {
                get {
                    "Hello World"
                }
            }
            """
        } diagnostics: {
            """
            @_SpyProperty("get", "RealType")
            ╰─ 🛑 @_SpyProperty can only be applied to variables without an existing accessor block
            var foo: String {
                get {
                    "Hello World"
                }
            }
            """
        }
    }

    func testPropertyWithGetterAndSetterDiagnostic() {
        assertMacro {
            """
            @_SpyProperty("get set", "RealType")
            var foo: String {
                get {
                    _foo
                }
                set {
                    _foo = newValue
                }
            }
            """
        } diagnostics: {
            """
            @_SpyProperty("get set", "RealType")
            ╰─ 🛑 @_SpyProperty can only be applied to variables without an existing accessor block
            var foo: String {
                get {
                    _foo
                }
                set {
                    _foo = newValue
                }
            }
            """
        }
    }

    func testImmutablePropertyDiagnostic() {
        assertMacro {
            """
            @_SpyProperty("get", "RealType")
            let foo: String = "Hello World"
            """
        } diagnostics: {
            """
            @_SpyProperty("get", "RealType")
            ╰─ 🛑 @_SpyProperty can only be applied to mutable variable declarations
            let foo: String = "Hello World"
            """
        }
    }

}

#endif

//
// Created on 5/27/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class MockPropertyMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["_MockProperty": MockPropertyMacro.self]) {
            super.invokeTest()
        }
    }

    func testPropertyWithoutInitializer() {
        assertMacro {
            """
            @_MockProperty
            var foo: String
            """
        } expansion: {
            """
            var foo: String {
                get {
                    stubValue()
                }
                set {
                    setStub(value: newValue)
                }
            }
            """
        }
    }

    /// Even though this property expands to not have its type specified, in use the compiler will still correctly infer its type.
    func testPropertyWithInitializer() {
        assertMacro {
            """
            @_MockProperty
            var foo = "Hello World"
            """
        } expansion: {
            """
            var foo {
                get {
                    stubValue()
                }
                set {
                    setStub(value: newValue)
                }
            }
            """
        }
    }

    func testPropertyWithInitializerAndTypeAnnotation() {
        assertMacro {
            """
            @_MockProperty
            var foo: String = "Hello World"
            """
        } expansion: {
            """
            var foo: String {
                get {
                    stubValue()
                }
                set {
                    setStub(value: newValue)
                }
            }
            """
        }
    }

    func testPropertyWithGetter() {
        assertMacro {
            """
            @_MockProperty
            var foo: String {
                "Hello World"
            }
            """
        } diagnostics: {
            """
            @_MockProperty
            ╰─ 🛑 @_MockProperty can only be applied to variables without an existing accessor block
            var foo: String {
                "Hello World"
            }
            """
        }
    }

    func testPropertyWithGetterAndSetter() {
        assertMacro {
            """
            @_MockProperty
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
            @_MockProperty
            ╰─ 🛑 @_MockProperty can only be applied to variables without an existing accessor block
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

    func testImmutableProperty() {
        assertMacro {
            """
            @_MockProperty
            let foo: String = "Hello World"
            """
        } diagnostics: {
            """
            @_MockProperty
            ╰─ 🛑 @_MockProperty can only be applied to mutable variable declarations
            let foo: String = "Hello World"
            """
        }
    }

}

#endif

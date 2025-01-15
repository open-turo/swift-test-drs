//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class AddMockMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["AddMock": AddMockMacro.self, "__MockProperty": MockPropertyMacro.self]) {
            super.invokeTest()
        }
    }

    func testAddMockMacro_WithEnum_ProducesDiagnostic() {
        assertMacro {
            """
            @AddMock
            enum SomeEnum {
                case foo
                case bar
            }
            """
        } diagnostics: {
            """
            @AddMock
            ┬───────
            ╰─ 🛑 @AddMock can only be applied to protocols, classes, and structs
            enum SomeEnum {
                case foo
                case bar
            }
            """
        }
    }

    func testAddMockMacro_WithActor_ProducesDiagnostic() {
        assertMacro {
            """
            @AddMock
            actor SomeActor {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        } diagnostics: {
            """
            @AddMock
            ┬───────
            ╰─ 🛑 @AddMock can only be applied to protocols, classes, and structs
            actor SomeActor {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testAddMockMacro_WithFinalClass_ProducesDiagnostic() {
        assertMacro {
            """
            @AddMock
            final class SomeClass {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        } diagnostics: {
            """
            @AddMock
            ┬───────
            ╰─ 🛑 @AddMock can't be applied to final classes as they can not be subclassed to produce a mock.
            final class SomeClass {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        }
    }

}

#endif

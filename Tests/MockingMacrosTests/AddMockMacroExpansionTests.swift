//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(MockingMacros)

import MacroTesting
import MockingMacros
import XCTest

final class AddMockMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["Mock": AddMockMacro.self, "__MockProperty": MockPropertyMacro.self]) {
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

            """
        } expansion: {
            """
            @AddMock
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

            """
        } expansion: {
            """
            @AddMock
            actor SomeActor {
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

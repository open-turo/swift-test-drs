//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class MockMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["Mock": MockMacro.self]) {
            super.invokeTest()
        }
    }

    func testMockMacro_WithEnum_ProducesDiagnostic() {
        assertMacro {
            """
            @Mock
            enum SomeEnum {
                case foo
                case bar
            }
            """
        } diagnostics: {
            """
            @Mock
            ┬────
            ╰─ 🛑 @Mock can only be applied to protocols, classes, and structs
            enum SomeEnum {
                case foo
                case bar
            }
            """
        }
    }

    func testMockMacro_WithActor_ProducesDiagnostic() {
        assertMacro {
            """
            @Mock
            actor SomeActor {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        } diagnostics: {
            """
            @Mock
            ┬────
            ╰─ 🛑 @Mock can only be applied to protocols, classes, and structs
            actor SomeActor {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testSomething() {
        assertMacro {
            """
            @Mock(options: .observableObject)
            class MyViewModel: ObservableObject {
                var someText: String = "Hello"
            }
            """
        } expansion: {
            """
            class MyViewModel: ObservableObject {
                var someText: String = "Hello"
            }

            #if DEBUG

            final class MockMyViewModel: MyViewModel, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var someText: String {
                    get {
                        stubOutput()
                    }
                    set {
                        objectWillChange.send()
                        setStub(value: newValue)
                    }
                }
            }

            #endif
            """
        }
    }

}

#endif

//
// Created on 6/20/24.
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

    func testStruct() {
        assertMacro {
            """
            @Mock
            struct SomeStruct {
                func foo() throws -> String
                func bar(with paramOne: String) -> Int
                func baz(with paramOne: String, for paramTwo: String) -> Bool
                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String
                mutating func rab(paramOne: Bool)
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                @_MockFunction
                func foo() throws -> String
                @_MockFunction
                func bar(with paramOne: String) -> Int
                @_MockFunction
                func baz(with paramOne: String, for paramTwo: String) -> Bool
                @_MockFunction
                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String
                @_MockFunction
                mutating func rab(paramOne: Bool)

                let blackBox = BlackBox(mockType: SomeStruct.self)

                let stubRegistry = StubRegistry(mockType: SomeStruct.self)
            }

            extension SomeStruct: Mock {
            }
            """
        }
    }

    /// Unlike @AddMock which does not include initializers in generated struct mocks,
    /// @Mock does not remove or prevent initializers from working.
    func testStructWithInit() {
        assertMacro {
            """
            @Mock
            struct SomeStruct {
                var x: String
                var y: Int
                var myZ: Bool

                init(_ x: String, y: Int, andZ z: Bool) {
                    self.x = x
                    self.y = y
                    myZ = z
                    self.x = "Hello World"
                    foo()
                }

                func foo()
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                @_MockProperty
                var x: String
                @_MockProperty
                var y: Int
                @_MockProperty
                var myZ: Bool

                init(_ x: String, y: Int, andZ z: Bool) {
                    self.x = x
                    self.y = y
                    myZ = z
                    self.x = "Hello World"
                    foo()
                }
                @_MockFunction

                func foo()

                let blackBox = BlackBox(mockType: SomeStruct.self)

                let stubRegistry = StubRegistry(mockType: SomeStruct.self)
            }

            extension SomeStruct: Mock {
            }
            """
        }
    }

    func testClass() {
        assertMacro {
            """
            @Mock
            class SomeClass {
                func foo() throws -> String
                func bar(with paramOne: String) -> Int
                func baz(with paramOne: String, for paramTwo: String) -> Bool
                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String
                mutating func rab(paramOne: Bool)
            }
            """
        } expansion: {
            """
            class SomeClass {
                @_MockFunction
                func foo() throws -> String
                @_MockFunction
                func bar(with paramOne: String) -> Int
                @_MockFunction
                func baz(with paramOne: String, for paramTwo: String) -> Bool
                @_MockFunction
                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String
                @_MockFunction
                mutating func rab(paramOne: Bool)

                let blackBox = BlackBox(mockType: SomeClass.self)

                let stubRegistry = StubRegistry(mockType: SomeClass.self)
            }

            extension SomeClass: Mock {
            }
            """
        }
    }

    func testClasWithInit() {
        assertMacro {
            """
            @Mock
            class SomeClass {
                var x: String
                var y: Int
                var myZ: Bool

                init(_ x: String, y: Int, andZ z: Bool) {
                    self.x = x
                    self.y = y
                    myZ = z
                    self.x = "Hello World"
                    foo()
                }

                func foo()
            }
            """
        } expansion: {
            """
            class SomeClass {
                @_MockProperty
                var x: String
                @_MockProperty
                var y: Int
                @_MockProperty
                var myZ: Bool

                init(_ x: String, y: Int, andZ z: Bool) {
                    self.x = x
                    self.y = y
                    myZ = z
                    self.x = "Hello World"
                    foo()
                }
                @_MockFunction

                func foo()

                let blackBox = BlackBox(mockType: SomeClass.self)

                let stubRegistry = StubRegistry(mockType: SomeClass.self)
            }

            extension SomeClass: Mock {
            }
            """
        }
    }

    func testFunctionBodiesProduceDiagnostics() {
        assertMacro {
            """
            @Mock
            struct SomeStruct {
                func foo() {
                    fatalError()
                }

                static func bar() {
                    fatalError()
                }
            }
            """
        } diagnostics: {
            """
            @Mock
            struct SomeStruct {
                func foo() {
                ╰─ 🛑 @Mock can't be applied to types containing functions that have bodies
                    fatalError()
                }

                static func bar() {
                ╰─ 🛑 @Mock can't be applied to types containing functions that have bodies
                    fatalError()
                }
            }
            """
        }
    }

    func testPropertyInitializersProduceDiagnostics() {
        assertMacro {
            """
            @Mock
            struct SomeStruct {
                var x = "Hello World"
                var y: Int = 0
            }
            """
        } diagnostics: {
            """
            @Mock
            struct SomeStruct {
                var x = "Hello World"
                ┬────────────────────
                ╰─ 🛑 @Mock can't be applied to types containing properties that have initializers
                var y: Int = 0
                ┬─────────────
                ╰─ 🛑 @Mock can't be applied to types containing properties that have initializers
            }
            """
        }
    }

    func testEnumProducesDiagnostic() {
        assertMacro {
            """
            @Mock
            enum SomeEnum {
                case one
                case two
                case three
            }
            """
        } diagnostics: {
            """
            @Mock
            ┬────
            ╰─ 🛑 @Mock can only be applied to classes and structs
            enum SomeEnum {
                case one
                case two
                case three
            }
            """
        }
    }

    func testProtocolProducesDiagnostic() {
        assertMacro {
            """
            @Mock
            protocol SomeProtocol {
                func foo()
                func bar(paramOne: String)
            }
            """
        } diagnostics: {
            """
            @Mock
            ┬────
            ╰─ 🛑 @Mock can only be applied to classes and structs
            protocol SomeProtocol {
                func foo()
                func bar(paramOne: String)
            }
            """
        }
    }
}

#endif

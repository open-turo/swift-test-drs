//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(MockingMacros)

import MacroTesting
import XCTest

extension AddMockMacroExpansionTests {

    func testAddMockMacro_WithStruct_WithMethods() {
        assertMacro {
            """
            @AddMock
            struct SomeStruct: ProtocolOne, ProtocolTwo {

                func foo() {
                    fatalError("Unimplemented")
                }

                func bar() -> Int {
                    fatalError("Unimplemented")
                }

                func baz(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }

                func oof() throws -> Int {
                    fatalError("Unimplemented")
                }

                func rab(paramOne: Int, paramTwo: String, paramThree: bool) -> Int {
                    fatalError("Unimplemented")
                }

                func zab(paramOne: Int) async throws -> Int {
                    fatalError("Unimplemented")
                }

            }
            """
        } expansion: {
            """
            @AddMock
            struct SomeStruct: ProtocolOne, ProtocolTwo {

                func foo() {
                    fatalError("Unimplemented")
                }

                func bar() -> Int {
                    fatalError("Unimplemented")
                }

                func baz(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }

                func oof() throws -> Int {
                    fatalError("Unimplemented")
                }

                func rab(paramOne: Int, paramTwo: String, paramThree: bool) -> Int {
                    fatalError("Unimplemented")
                }

                func zab(paramOne: Int) async throws -> Int {
                    fatalError("Unimplemented")
                }

            }
            """
        }
    }

    func testAddMockMacro_WithStruct_WithStaticMembers() {
        assertMacro {
            """
            @AddMock
            struct SomeStruct {
                var foo = "Hello World"
                static var bar = 7
                static var baz: Bool { true }

                static func oof(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }
            }
            """
        } expansion: {
            """
            @AddMock
            struct SomeStruct {
                var foo = "Hello World"
                static var bar = 7
                static var baz: Bool { true }

                static func oof(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testAddMockMacro_WithStruct_WithComputedProperties() {
        assertMacro {
            """
            @AddMock
            struct SomeStruct {
                var foo: String {
                    "Hello World"
                }

                var bar: String {
                    get { "Hello World" }
                }

                var baz: String {
                    get { "Hello World" }
                    set {}
                }

            }
            """
        } expansion: {
            """
            @AddMock
            struct SomeStruct {
                var foo: String {
                    "Hello World"
                }

                var bar: String {
                    get { "Hello World" }
                }

                var baz: String {
                    get { "Hello World" }
                    set {}
                }

            }
            """
        }
    }

    func testAddMockMacro_WithStruct_WithOptionalAndImplicitlyUnwrappedOptional() {
        assertMacro {
            """
            @AddMock
            struct SomeStruct {

                var foo: String?
                let bar: Int!

            }
            """
        } expansion: {
            """
            @AddMock
            struct SomeStruct {

                var foo: String?
                let bar: Int!

            }
            """
        }
    }

    func testAddMockMacro_WithStruct_DoesNotMockPrivateMembers() {
        assertMacro {
            """
            @AddMock
            struct SomeStruct {

                var foo: String

                private var bar: String
                private var baz: Int!

                func oof() {
                    fatalError("Unimplemented")
                }

                private func rab() {
                    fatalError("Unimplemented")
                }
            }
            """
        } expansion: {
            """
            @AddMock
            struct SomeStruct {

                var foo: String

                private var bar: String
                private var baz: Int!

                func oof() {
                    fatalError("Unimplemented")
                }

                private func rab() {
                    fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testAddMockMacro_WithNestedStruct() {
        assertMacro {
            """
            @AddMock
            struct SomeStruct {

                struct NestedStruct {
                    let nestedFoo: String
                    func nestedBar() {
                        fatalError("Unimplemented")
                    }
                }

                var foo: NestedStruct

                func bar() {
                    fatalError("Unimplemented")
                }
            }
            """
        } expansion: {
            """
            @AddMock
            struct SomeStruct {

                struct NestedStruct {
                    let nestedFoo: String
                    func nestedBar() {
                        fatalError("Unimplemented")
                    }
                }

                var foo: NestedStruct

                func bar() {
                    fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testAddMockMacro_AppliedToNestedStruct() {
        assertMacro {
            """
            struct SomeStruct {

                @AddMock
                struct NestedStruct {
                    let nestedFoo: String
                    func nestedBar() {
                        fatalError("Unimplemented")
                    }
                }

                var foo: NestedStruct

                func bar() {
                    fatalError("Unimplemented")
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct {

                @AddMock
                struct NestedStruct {
                    let nestedFoo: String
                    func nestedBar() {
                        fatalError("Unimplemented")
                    }
                }

                var foo: NestedStruct

                func bar() {
                    fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testAddMockMacro_WithGenericStruct() {
        assertMacro {
            """
            @AddMock
            struct SomeStruct<T> {

                var foo: T

                func bar() -> T {
                    fatalError("Unimplemented")
                }

            }
            """
        } expansion: {
            """
            @AddMock
            struct SomeStruct<T> {

                var foo: T

                func bar() -> T {
                    fatalError("Unimplemented")
                }

            }
            """
        }
    }

    func testAddMockMacro_WithStruct_WithInit() {
        assertMacro {
            """
            @AddMock
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

                func foo() {}
            }
            """
        } expansion: {
            """
            @AddMock
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

                func foo() {}
            }
            """
        }
    }

    /// Even though properties x, y, and z expand to not have the type specified, in use the compiler will still properly infer their types.
    /// The user will see the properties like `@__MockProperty` var x = "Hello World" when viewing the macro expansion.
    func testAddMockMacro_WithStruct_WithStoredProperties() {
        assertMacro {
            """
            @AddMock
            struct SomeStruct {
                let a: String = "Hello World"
                var b: [Int] = [1, 2, 3]
                var c: [String: Bool] = ["YES": true, "NO": false]

                let x = "Hello World"
                var y = [1, 2, 3]
                var z = ["YES": true, "NO": false]
            }
            """
        } expansion: {
            """
            @AddMock
            struct SomeStruct {
                let a: String = "Hello World"
                var b: [Int] = [1, 2, 3]
                var c: [String: Bool] = ["YES": true, "NO": false]

                let x = "Hello World"
                var y = [1, 2, 3]
                var z = ["YES": true, "NO": false]
            }
            """
        }
    }

}
#endif

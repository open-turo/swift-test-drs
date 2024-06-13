//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(MockingMacros)

import MacroTesting
import XCTest

extension AddMockMacroExpansionTests {

    func testAddMockMacro_WithClass_WithMethods() {
        assertMacro {
            """
            @AddMock
            class SomeClass: ProtocolOne, ProtocolTwo {

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

                func zab(paramOne: Int) async throws -> (() -> Void) {
                    fatalError("Unimplemented")
                }

            }
            """
        } expansion: {
            """
            @AddMock
            class SomeClass: ProtocolOne, ProtocolTwo {

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

                func zab(paramOne: Int) async throws -> (() -> Void) {
                    fatalError("Unimplemented")
                }

            }
            """
        }
    }

    func testAddMockMacro_WithClass_WithClassMembers() {
        assertMacro {
            """
            @AddMock
            class SomeClass {
                var foo = "Hello World"
                class var bar: Int {
                    get { 7 }
                    set {}
                }
                class var baz: Bool { true }

                class func oof(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }
            }
            """
        } expansion: {
            """
            @AddMock
            class SomeClass {
                var foo = "Hello World"
                class var bar: Int {
                    get { 7 }
                    set {}
                }
                class var baz: Bool { true }

                class func oof(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testAddMockMacro_WithClass_DoesNotMockStaticMembers() {
        assertMacro {
            """
            @AddMock
            class SomeClass {
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
            class SomeClass {
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

    func testAddMockMacro_WithSubclass() {
        assertMacro {
            """
            @AddMock
            class SomeClass: SomeSuperclass {
                override var foo = "Hello World"

                override func bar() -> Int {
                    fatalError("Unimplemented")
                }
            }
            """
        } expansion: {
            """
            @AddMock
            class SomeClass: SomeSuperclass {
                override var foo = "Hello World"

                override func bar() -> Int {
                    fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testAddMockMacro_WithClass_WithComputedProperties() {
        assertMacro {
            """
            @AddMock
            class SomeClass {
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
            class SomeClass {
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

    func testAddMockMacro_WithClass_WithOptionalAndImplicitlyUnwrappedOptional() {
        assertMacro {
            """
            @AddMock
            class SomeClass {
                var foo: String?
                let bar: Int!
            }
            """
        } expansion: {
            """
            @AddMock
            class SomeClass {
                var foo: String?
                let bar: Int!
            }
            """
        }
    }

    func testAddMockMacro_WithClass_DoesNotMockPrivateMembers() {
        assertMacro {
            """
            @AddMock
            class SomeClass {
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
            class SomeClass {
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

    func testAddMockMacro_WithClass_WithInit() {
        assertMacro {
            """
            @AddMock
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

                func foo() {}
            }
            """
        } expansion: {
            """
            @AddMock
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

                func foo() {}
            }
            """
        }
    }

    func testAddMockMacro_WithClass_DoesNotMockPrivateInit() {
        assertMacro {
            """
            @AddMock
            class SomeClass {
                var x: String
                var y: Int
                var z: Bool

                init(x: String, y: Int, z: Bool) {
                    self.x = x
                    self.y = y
                    self.z = z
                }

                private init() {
                    x = "Hello World"
                    y = 27
                    z = true
                }

            }
            """
        } expansion: {
            """
            @AddMock
            class SomeClass {
                var x: String
                var y: Int
                var z: Bool

                init(x: String, y: Int, z: Bool) {
                    self.x = x
                    self.y = y
                    self.z = z
                }

                private init() {
                    x = "Hello World"
                    y = 27
                    z = true
                }

            }
            """
        }
    }

    func testAddMockMacro_WithClass_WithFinalMembers() {
        assertMacro {
            """
            @AddMock
            class SomeClass {
                var x = "Hello World"
                final let y = 7
                final var z: Bool = true

                final func foo() {}
            }
            """
        } expansion: {
            """
            @AddMock
            class SomeClass {
                var x = "Hello World"
                final let y = 7
                final var z: Bool = true

                final func foo() {}
            }
            """
        }
    }

}
#endif

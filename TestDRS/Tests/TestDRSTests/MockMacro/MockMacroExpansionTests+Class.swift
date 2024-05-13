//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

extension MockMacroExpansionTests {

    func testMockMacro_WithClass_WithMethods() {
        assertMacro {
            """
            @Mock
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

                func zab(paramOne: Int) async throws -> Int {
                    fatalError("Unimplemented")
                }

            }
            """
        } expansion: {
            """
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

                func zab(paramOne: Int) async throws -> Int {
                    fatalError("Unimplemented")
                }

            }

            #if DEBUG

            class MockSomeClass: SomeClass, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                override func foo() {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: Void())
                }

                override func bar() -> Int {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: stubOutput())
                }

                override func baz(paramOne: String) -> Int {
                    let callTime = Date()
                    return recordCall(
                        with: paramOne,
                        at: callTime,
                        returning: stubOutput(for: paramOne)
                    )
                }

                override func oof() throws -> Int {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: try throwingStubOutput())
                }

                override func rab(paramOne: Int, paramTwo: String, paramThree: bool) -> Int {
                    let callTime = Date()
                    return recordCall(
                        with: (paramOne, paramTwo, paramThree),
                        at: callTime,
                        returning: stubOutput(for: (paramOne, paramTwo, paramThree))
                    )
                }

                override func zab(paramOne: Int) async throws -> Int {
                    let callTime = Date()
                    return recordCall(
                        with: paramOne,
                        at: callTime,
                        returning: try throwingStubOutput(for: paramOne)
                    )
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithClass_WithClassMembers() {
        assertMacro {
            """
            @Mock
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

            #if DEBUG

            class MockSomeClass: SomeClass, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                override var foo {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                class override var bar: Int {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                class override var baz: Bool {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                class override func oof(paramOne: String) -> Int {
                    let callTime = Date()
                    return recordCall(
                        with: paramOne,
                        at: callTime,
                        returning: stubOutput(for: paramOne)
                    )
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithClass_DoesNotMockStaticMembers() {
        assertMacro {
            """
            @Mock
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
            class SomeClass {
                var foo = "Hello World"
                static var bar = 7
                static var baz: Bool { true }

                static func oof(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }
            }

            #if DEBUG

            class MockSomeClass: SomeClass, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                override var foo {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
            }

            #endif
            """
        }
    }

    func testMockMacro_WithClass_WithComputedProperties() {
        assertMacro {
            """
            @Mock
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

            #if DEBUG

            class MockSomeClass: SomeClass, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                override var foo: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                override var bar: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                override var baz: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
            }

            #endif
            """
        }
    }

    func testMockMacro_WithClass_WithOptionalAndImplicitlyUnwrappedOptional() {
        assertMacro {
            """
            @Mock
            class SomeClass {

                var foo: String?
                let bar: Int!

            }
            """
        } expansion: {
            """
            class SomeClass {

                var foo: String?
                let bar: Int!

            }

            #if DEBUG

            class MockSomeClass: SomeClass, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                override var foo: String? {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                override var bar: Int! {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
            }

            #endif
            """
        }
    }

    func testMockMacro_WithClass_DoesNotMockPrivateMembers() {
        assertMacro {
            """
            @Mock
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

            #if DEBUG

            class MockSomeClass: SomeClass, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                override var foo: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                override func oof() {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: Void())
                }

            }

            #endif
            """
        }
    }

}
#endif

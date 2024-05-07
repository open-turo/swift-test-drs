//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

extension MockMacroExpansionTests {

    func testMockMacro_WithStruct_WithMethods() {
        assertMacro {
            """
            @Mock
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

            #if DEBUG

            struct MockSomeStruct: ProtocolOne, ProtocolTwo, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                func foo() {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: Void())
                }

                func bar() -> Int {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: stubOutput())
                }

                func baz(paramOne: String) -> Int {
                    let callTime = Date()
                    return recordCall(
                        with: paramOne,
                        at: callTime,
                        returning: stubOutput(for: paramOne)
                    )
                }

                func oof() throws -> Int {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: try throwingStubOutput())
                }

                func rab(paramOne: Int, paramTwo: String, paramThree: bool) -> Int {
                    let callTime = Date()
                    return recordCall(
                        with: (paramOne, paramTwo, paramThree),
                        at: callTime,
                        returning: stubOutput(for: (paramOne, paramTwo, paramThree))
                    )
                }

                func zab(paramOne: Int) async throws -> Int {
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

    func testMockMacro_WithStruct_WithStaticMembers() {
        assertMacro {
            """
            @Mock
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
            struct SomeStruct {
                var foo = "Hello World"
                static var bar = 7
                static var baz: Bool { true }

                static func oof(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }
            }

            #if DEBUG

            struct MockSomeStruct: Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let staticMock = StaticMock()

                var foo {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                static var bar {
                    get {
                        staticMock.stubOutput()
                    }
                    set {
                        staticMock.setStub(value: newValue)
                    }
                }

                static var baz: Bool {
                    get {
                        staticMock.stubOutput()
                    }
                    set {
                        staticMock.setStub(value: newValue)
                    }
                }

                static func oof(paramOne: String) -> Int {
                    let callTime = Date()
                    return staticMock.recordCall(
                        with: paramOne,
                        at: callTime,
                        returning: staticMock.stubOutput(for: paramOne)
                    )
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithStruct_WithComputedProperties() {
        assertMacro {
            """
            @Mock
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

            #if DEBUG

            struct MockSomeStruct: Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                var foo: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                var bar: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                var baz: String {
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

    func testMockMacro_WithStruct_WithOptionalAndImplicitlyUnwrappedOptional() {
        assertMacro {
            """
            @Mock
            struct SomeStruct {

                var foo: String?
                let bar: Int!

            }
            """
        } expansion: {
            """
            struct SomeStruct {

                var foo: String?
                let bar: Int!

            }

            #if DEBUG

            struct MockSomeStruct: Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                var foo: String? {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                var bar: Int! {
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

    func testMockMacro_WithStruct_DoesNotMockPrivateMembers() {
        assertMacro {
            """
            @Mock
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

            #if DEBUG

            struct MockSomeStruct: Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                var foo: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                func oof() {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: Void())
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithNestedStruct() {
        assertMacro {
            """
            @Mock
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

            #if DEBUG

            struct MockSomeStruct: Spy, StubProviding {

                struct NestedStruct {
                    let nestedFoo: String
                    func nestedBar() {
                        fatalError("Unimplemented")
                    }
                }

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                var foo: NestedStruct {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                func bar() {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: Void())
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_AppliedToNestedStruct() {
        assertMacro {
            """
            struct SomeStruct {

                @Mock
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
                struct NestedStruct {
                    let nestedFoo: String
                    func nestedBar() {
                        fatalError("Unimplemented")
                    }
                }

                #if DEBUG

                struct MockNestedStruct: Spy, StubProviding {

                    let blackBox = BlackBox()
                    let stubRegistry = StubRegistry()

                    var nestedFoo: String {
                        get {
                            stubOutput()
                        }
                        set {
                            setStub(value: newValue)
                        }
                    }

                    func nestedBar() {
                        let callTime = Date()
                        return recordCall(at: callTime, returning: Void())
                    }

                }

                #endif

                var foo: NestedStruct

                func bar() {
                    fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testMockMacro_WithGenericStruct() {
        assertMacro {
            """
            @Mock
            struct SomeStruct<T> {

                var foo: T

                func bar() -> T {
                    fatalError("Unimplemented")
                }

            }
            """
        } expansion: {
            """
            struct SomeStruct<T> {

                var foo: T

                func bar() -> T {
                    fatalError("Unimplemented")
                }

            }

            #if DEBUG

            struct MockSomeStruct<T> : Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                var foo: T {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                func bar() -> T {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: stubOutput())
                }

            }

            #endif
            """
        }
    }

}
#endif

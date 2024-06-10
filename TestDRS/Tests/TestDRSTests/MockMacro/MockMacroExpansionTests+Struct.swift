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

            struct MockSomeStruct: ProtocolOne, ProtocolTwo, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                func foo() {
                    recordCall()
                    return stubOutput()
                }

                func bar() -> Int {
                    recordCall(returning: Int.self)
                    return stubOutput()
                }

                func baz(paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return stubOutput(for: paramOne)
                }

                func oof() throws -> Int {
                    recordCall(returning: Int.self)
                    return try throwingStubOutput()
                }

                func rab(paramOne: Int, paramTwo: String, paramThree: bool) -> Int {
                    recordCall(with: (paramOne, paramTwo, paramThree), returning: Int.self)
                    return stubOutput(for: (paramOne, paramTwo, paramThree))
                }

                func zab(paramOne: Int) async throws -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return try throwingStubOutput(for: paramOne)
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

            struct MockSomeStruct: Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

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
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                static var baz: Bool {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                static func oof(paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return stubOutput(for: paramOne)
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

            struct MockSomeStruct: Mock {

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

            struct MockSomeStruct: Mock {

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

            struct MockSomeStruct: Mock {

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
                    recordCall()
                    return stubOutput()
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

            struct MockSomeStruct: Mock {

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
                    recordCall()
                    return stubOutput()
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

                struct MockNestedStruct: Mock {

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
                        recordCall()
                        return stubOutput()
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

            struct MockSomeStruct<T> : Mock {

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
                    recordCall(returning: T.self)
                    return stubOutput()
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithStruct_WithInit() {
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

                func foo() {}
            }
            """
        } expansion: {
            """
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

            #if DEBUG

            struct MockSomeStruct: Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                var x: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                var y: Int {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                var myZ: Bool {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                func foo() {
                    recordCall()
                    return stubOutput()
                }

            }

            #endif
            """
        }
    }

}
#endif

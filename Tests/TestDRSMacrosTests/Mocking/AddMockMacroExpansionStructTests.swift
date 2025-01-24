//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

final class AddMockMacroExpansionStructTests: AddMockMacroExpansionTestCase {

    func testStructWithMethods() {
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

    func testStructWithStaticMembers() {
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
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                static var bar {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                static var baz: Bool {
                    get {
                        stubValue()
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

    func testStructWithComputedProperties() {
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
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var bar: String {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var baz: String {
                    get {
                        stubValue()
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

    func testStructWithOptionalAndImplicitlyUnwrappedOptional() {
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
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var bar: Int! {
                    get {
                        stubValue()
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

    func testDoesNotMockPrivateMembers() {
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
                        stubValue()
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

    func testStructWithNestedStruct() {
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
                        stubValue()
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

    func testMacroAppliedToNestedStruct() {
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
                            stubValue()
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

    func testGenericStruct() {
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
                        stubValue()
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

    func testStructWithInit() {
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
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var y: Int {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var myZ: Bool {
                    get {
                        stubValue()
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

    /// Even though properties x, y, and z do not have types specified in the expanded mock, in use the compiler will still properly infer their types.
    /// The user will see the properties like `@_MockProperty` var x = "Hello World" when viewing the macro expansion.
    func testStructWithStoredProperties() {
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
            struct SomeStruct {
                let a: String = "Hello World"
                var b: [Int] = [1, 2, 3]
                var c: [String: Bool] = ["YES": true, "NO": false]

                let x = "Hello World"
                var y = [1, 2, 3]
                var z = ["YES": true, "NO": false]
            }

            #if DEBUG

            struct MockSomeStruct: Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                var a: String {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var b: [Int] {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var c: [String: Bool] {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var x {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var y {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                var z {
                    get {
                        stubValue()
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

}
#endif

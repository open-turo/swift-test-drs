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

                func zab(paramOne: Int) async throws -> (() -> Void) {
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

                func zab(paramOne: Int) async throws -> (() -> Void) {
                    fatalError("Unimplemented")
                }

            }

            #if DEBUG

            final class MockSomeClass: SomeClass, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                override func foo() {
                    recordCall()
                    return stubOutput()
                }

                override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return stubOutput()
                }

                override func baz(paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return stubOutput(for: paramOne)
                }

                override func oof() throws -> Int {
                    recordCall(returning: Int.self)
                    return try throwingStubOutput()
                }

                override func rab(paramOne: Int, paramTwo: String, paramThree: bool) -> Int {
                    recordCall(with: (paramOne, paramTwo, paramThree), returning: Int.self)
                    return stubOutput(for: (paramOne, paramTwo, paramThree))
                }

                override func zab(paramOne: Int) async throws -> (() -> Void) {
                    recordCall(with: paramOne, returning: (() -> Void).self)
                    return try throwingStubOutput(for: paramOne)
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

            final class MockSomeClass: SomeClass, Spy, StubProviding {

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
                    recordCall(with: paramOne, returning: Int.self)
                    return stubOutput(for: paramOne)
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

            final class MockSomeClass: SomeClass, Spy, StubProviding {

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

    func testMockMacro_WithSubclass() {
        assertMacro {
            """
            @Mock
            class SomeClass: SomeSuperclass {
                override var foo = "Hello World"

                override func bar() -> Int {
                    fatalError("Unimplemented")
                }
            }
            """
        } expansion: {
            """
            class SomeClass: SomeSuperclass {
                override var foo = "Hello World"

                override func bar() -> Int {
                    fatalError("Unimplemented")
                }
            }

            #if DEBUG

            final class MockSomeClass: SomeClass, Spy, StubProviding {

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

                override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return stubOutput()
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

            final class MockSomeClass: SomeClass, Spy, StubProviding {

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

            final class MockSomeClass: SomeClass, Spy, StubProviding {

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

            final class MockSomeClass: SomeClass, Spy, StubProviding {

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

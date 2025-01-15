//
// Created on 5/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

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

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

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

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var foo {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                class override var bar: Int {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                class override var baz: Bool {
                    get {
                        stubValue()
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
            class SomeClass {
                var foo = "Hello World"
                static var bar = 7
                static var baz: Bool { true }

                static func oof(paramOne: String) -> Int {
                    fatalError("Unimplemented")
                }
            }

            #if DEBUG

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var foo {
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
            class SomeClass: SomeSuperclass {
                override var foo = "Hello World"

                override func bar() -> Int {
                    fatalError("Unimplemented")
                }
            }

            #if DEBUG

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var foo {
                    get {
                        stubValue()
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

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var foo: String {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                override var bar: String {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                override var baz: String {
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
            class SomeClass {
                var foo: String?
                let bar: Int!
            }

            #if DEBUG

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var foo: String? {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                override var bar: Int! {
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

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var foo: String {
                    get {
                        stubValue()
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

            #if DEBUG

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var x: String {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                override var y: Int {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                override var myZ: Bool {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                override init(_ x: String, y: Int, andZ z: Bool) {
                    super.init(x, y: y, andZ: z)
                    self.x = x
                    self.y = y
                    myZ = z
                }

                override func foo() {
                    recordCall()
                    return stubOutput()
                }

            }

            #endif
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

            #if DEBUG

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var x: String {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                override var y: Int {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }
                override var z: Bool {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                override init(x: String, y: Int, z: Bool) {
                    super.init(x: x, y: y, z: z)
                    self.x = x
                    self.y = y
                    self.z = z
                }
            }

            #endif
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
            class SomeClass {
                var x = "Hello World"
                final let y = 7
                final var z: Bool = true

                final func foo() {}
            }

            #if DEBUG

            final class MockSomeClass: SomeClass, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                override var x {
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

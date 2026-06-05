//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

final class AddSpyMacroExpansionStructTests: AddSpyMacroExpansionTestCase {

    func testStructWithMethods() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct: ProtocolOne, ProtocolTwo {

                func foo() {
                    // Implementation
                }

                func bar() -> Int {
                    return 42
                }

                func baz(paramOne: String) -> Int {
                    return paramOne.count
                }

                func oof() throws -> Int {
                    return 7
                }

                func rab(paramOne: Int, paramTwo: String, paramThree: Bool) -> Int {
                    return paramOne
                }

                func zab(paramOne: Int) async throws -> Int {
                    return paramOne * 2
                }

            }
            """
        } expansion: {
            """
            struct SomeStruct: ProtocolOne, ProtocolTwo {

                func foo() {
                    // Implementation
                }

                func bar() -> Int {
                    return 42
                }

                func baz(paramOne: String) -> Int {
                    return paramOne.count
                }

                func oof() throws -> Int {
                    return 7
                }

                func rab(paramOne: Int, paramTwo: String, paramThree: Bool) -> Int {
                    return paramOne
                }

                func zab(paramOne: Int) async throws -> Int {
                    return paramOne * 2
                }

            }

            #if DEBUG

            struct SpySomeStruct: ProtocolOne, ProtocolTwo, Spy {

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                init(real: SomeStruct) {
                    self.real = real
                }

                func foo() {
                    recordCall()
                    real.foo()
                }

                func bar() -> Int {
                    recordCall(returning: Int.self)
                    return real.bar()
                }

                func baz(paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return real.baz(paramOne: paramOne)
                }

                func oof() throws -> Int {
                    recordCall(returning: Int.self)
                    return try real.oof()
                }

                func rab(paramOne: Int, paramTwo: String, paramThree: Bool) -> Int {
                    recordCall(with: (paramOne, paramTwo, paramThree), returning: Int.self)
                    return real.rab(paramOne: paramOne, paramTwo: paramTwo, paramThree: paramThree)
                }

                func zab(paramOne: Int) async throws -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return try await real.zab(paramOne: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testStructWithStaticMembers() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct {
                var foo: String
                static var bar = 7
                static var baz: Bool { true }

                static func oof(paramOne: String) -> Int {
                    return paramOne.count
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                var foo: String
                static var bar = 7
                static var baz: Bool { true }

                static func oof(paramOne: String) -> Int {
                    return paramOne.count
                }
            }

            #if DEBUG

            struct SpySomeStruct: Spy {

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                var foo: String {
                    get {
                        real.foo
                    }
                    set {
                        real.foo = newValue
                    }
                }
                static var bar {
                    get {
                        SomeStruct.bar
                    }
                    set {
                        SomeStruct.bar = newValue
                    }
                }
                static var baz: Bool {
                    get {
                        SomeStruct.baz
                    }
                }

                init(real: SomeStruct) {
                    self.real = real
                }

                static func oof(paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return SomeStruct.oof(paramOne: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testStructWithComputedProperties() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct {
                var foo: String {
                    get { "Hello" }
                    set {}
                }

                var bar: Int {
                    get { 42 }
                }

                var baz: Bool {
                    get { true }
                    set {}
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                var foo: String {
                    get { "Hello" }
                    set {}
                }

                var bar: Int {
                    get { 42 }
                }

                var baz: Bool {
                    get { true }
                    set {}
                }
            }

            #if DEBUG

            struct SpySomeStruct: Spy {

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                var foo: String {
                    get {
                        real.foo
                    }
                    set {
                        real.foo = newValue
                    }
                }
                var bar: Int {
                    get {
                        real.bar
                    }
                }
                var baz: Bool {
                    get {
                        real.baz
                    }
                    set {
                        real.baz = newValue
                    }
                }

                init(real: SomeStruct) {
                    self.real = real
                }
            }

            #endif
            """
        }
    }

    func testStructWithOptionalAndImplicitlyUnwrappedOptional() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct {
                var foo: String?
                var bar: Int!

                func baz() -> Bool {
                    return true
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                var foo: String?
                var bar: Int!

                func baz() -> Bool {
                    return true
                }
            }

            #if DEBUG

            struct SpySomeStruct: Spy {

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                var foo: String? {
                    get {
                        real.foo
                    }
                    set {
                        real.foo = newValue
                    }
                }
                var bar: Int! {
                    get {
                        real.bar
                    }
                    set {
                        real.bar = newValue
                    }
                }

                init(real: SomeStruct) {
                    self.real = real
                }

                func baz() -> Bool {
                    recordCall(returning: Bool.self)
                    return real.baz()
                }

            }

            #endif
            """
        }
    }

    func testDoesNotSpyPrivateMembers() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct {
                var foo = "Hello World"
                private var bar = 7
                private func baz() -> Bool {
                    return true
                }

                func oof() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                var foo = "Hello World"
                private var bar = 7
                private func baz() -> Bool {
                    return true
                }

                func oof() -> Int {
                    return 42
                }
            }

            #if DEBUG

            struct SpySomeStruct: Spy {

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                var foo {
                    get {
                        real.foo
                    }
                    set {
                        real.foo = newValue
                    }
                }

                init(real: SomeStruct) {
                    self.real = real
                }

                func oof() -> Int {
                    recordCall(returning: Int.self)
                    return real.oof()
                }

            }

            #endif
            """
        }
    }

    func testStructWithNestedStruct() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct {
                struct NestedStruct {
                    let value: String
                }

                func foo() -> NestedStruct {
                    return NestedStruct(value: "test")
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                struct NestedStruct {
                    let value: String
                }

                func foo() -> NestedStruct {
                    return NestedStruct(value: "test")
                }
            }

            #if DEBUG

            struct SpySomeStruct: Spy {
                struct NestedStruct {
                    let value: String
                }

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                init(real: SomeStruct) {
                    self.real = real
                }

                func foo() -> NestedStruct {
                    recordCall(returning: NestedStruct.self)
                    return real.foo()
                }

            }

            #endif
            """
        }
    }

    func testMacroAppliedToNestedStruct() {
        assertMacro {
            """
            struct OuterStruct {
                @AddSpy
                struct InnerStruct {
                    func foo() -> String {
                        return "test"
                    }
                }
            }
            """
        } expansion: {
            """
            struct OuterStruct {
                struct InnerStruct {
                    func foo() -> String {
                        return "test"
                    }
                }

                #if DEBUG

                struct SpyInnerStruct: Spy {

                    let blackBox = BlackBox(mockType: SpyInnerStruct.self)
                    private var real: InnerStruct

                    init(real: InnerStruct) {
                        self.real = real
                    }

                    func foo() -> String {
                        recordCall(returning: String.self)
                        return real.foo()
                    }

                }

                #endif
            }
            """
        }
    }

    func testGenericStruct() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct<T> {
                var foo: T

                func bar() -> T {
                    return foo
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct<T> {
                var foo: T

                func bar() -> T {
                    return foo
                }
            }

            #if DEBUG

            struct SpySomeStruct<T> : Spy {

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                var foo: T {
                    get {
                        real.foo
                    }
                    set {
                        real.foo = newValue
                    }
                }

                init(real: SomeStruct) {
                    self.real = real
                }

                func bar() -> T {
                    recordCall(returning: T.self)
                    return real.bar()
                }

            }

            #endif
            """
        }
    }

    func testStructWithInit() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct {
                let foo: String

                init(foo: String) {
                    self.foo = foo
                }

                func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                let foo: String

                init(foo: String) {
                    self.foo = foo
                }

                func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            struct SpySomeStruct: Spy {

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                var foo: String {
                    get {
                        real.foo
                    }
                }

                init(real: SomeStruct) {
                    self.real = real
                }

                func bar() -> Int {
                    recordCall(returning: Int.self)
                    return real.bar()
                }

            }

            #endif
            """
        }
    }

    func testStructWithStoredProperties() {
        assertMacro {
            """
            @AddSpy
            struct SomeStruct {
                let immutableProp: String
                var mutableProp: Int

                func foo() -> Bool {
                    return true
                }
            }
            """
        } expansion: {
            """
            struct SomeStruct {
                let immutableProp: String
                var mutableProp: Int

                func foo() -> Bool {
                    return true
                }
            }

            #if DEBUG

            struct SpySomeStruct: Spy {

                let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                var immutableProp: String {
                    get {
                        real.immutableProp
                    }
                }
                var mutableProp: Int {
                    get {
                        real.mutableProp
                    }
                    set {
                        real.mutableProp = newValue
                    }
                }

                init(real: SomeStruct) {
                    self.real = real
                }

                func foo() -> Bool {
                    recordCall(returning: Bool.self)
                    return real.foo()
                }

            }

            #endif
            """
        }
    }

    func testPublicStruct() {
        assertMacro {
            """
            @AddSpy
            public struct SomeStruct {
                public var foo: String

                public init(foo: String) {
                    self.foo = foo
                }

                public func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            public struct SomeStruct {
                public var foo: String

                public init(foo: String) {
                    self.foo = foo
                }

                public func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            public struct SpySomeStruct: Spy {

                public let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                public var foo: String {
                    get {
                        real.foo
                    }
                    set {
                        real.foo = newValue
                    }
                }

                public init(real: SomeStruct) {
                    self.real = real
                }

                public func bar() -> Int {
                    recordCall(returning: Int.self)
                    return real.bar()
                }

            }

            #endif
            """
        }
    }

    func testPublicStructWithoutInit() {
        assertMacro {
            """
            @AddSpy
            public struct SomeStruct {
                public var foo: String

                public func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            public struct SomeStruct {
                public var foo: String

                public func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            public struct SpySomeStruct: Spy {

                public let blackBox = BlackBox(mockType: SpySomeStruct.self)
                private var real: SomeStruct

                public var foo: String {
                    get {
                        real.foo
                    }
                    set {
                        real.foo = newValue
                    }
                }

                public init(real: SomeStruct) {
                    self.real = real
                }

                public func bar() -> Int {
                    recordCall(returning: Int.self)
                    return real.bar()
                }

            }

            #endif
            """
        }
    }

}

#endif

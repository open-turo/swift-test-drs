//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

final class AddSpyMacroExpansionClassTests: AddSpyMacroExpansionTestCase {

    func testClassWithMethods() {
        assertMacro {
            """
            @AddSpy
            class SomeClass: ProtocolOne, ProtocolTwo {

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

                func zab(paramOne: Int) async throws -> (() -> Void) {
                    return {}
                }

            }
            """
        } expansion: {
            """
            class SomeClass: ProtocolOne, ProtocolTwo {

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

                func zab(paramOne: Int) async throws -> (() -> Void) {
                    return {}
                }

            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override func foo() {
                    recordCall()
                    super.foo()
                }

                override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return super.bar()
                }

                override func baz(paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return super.baz(paramOne: paramOne)
                }

                override func oof() throws -> Int {
                    recordCall(returning: Int.self)
                    return try super.oof()
                }

                override func rab(paramOne: Int, paramTwo: String, paramThree: Bool) -> Int {
                    recordCall(with: (paramOne, paramTwo, paramThree), returning: Int.self)
                    return super.rab(paramOne: paramOne, paramTwo: paramTwo, paramThree: paramThree)
                }

                override func zab(paramOne: Int) async throws -> (() -> Void) {
                    recordCall(with: paramOne, returning: (() -> Void).self)
                    return try await super.zab(paramOne: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testClassWithClassMembers() {
        assertMacro {
            """
            @AddSpy
            class SomeClass {
                var foo = "Hello World"
                class var bar: Int {
                    get { 7 }
                    set {}
                }
                class var baz: Bool { true }

                class func oof(paramOne: String) -> Int {
                    return paramOne.count
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
                    return paramOne.count
                }
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }
                class override var bar: Int {
                    get {
                        super.bar
                    }
                    set {
                        super.bar = newValue
                    }
                }
                class override var baz: Bool {
                    get {
                        super.baz
                    }
                }

                class override func oof(paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return super.oof(paramOne: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testDoesNotSpyStaticMembers() {
        assertMacro {
            """
            @AddSpy
            class SomeClass {
                var foo = "Hello World"
                static var bar = 7
                static var baz: Bool { true }

                static func oof(paramOne: String) -> Int {
                    return paramOne.count
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
                    return paramOne.count
                }
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }
            }

            #endif
            """
        }
    }

    func testClassWithSuperclass() {
        assertMacro {
            """
            @AddSpy
            class SomeClass: SomeSuperclass {
                override var foo = "Hello World"
                override func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            class SomeClass: SomeSuperclass {
                override var foo = "Hello World"
                override func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }

                override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return super.bar()
                }

            }

            #endif
            """
        }
    }

    func testClassWithComputedProperties() {
        assertMacro {
            """
            @AddSpy
            class SomeClass {
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
            class SomeClass {
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

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo: String {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }
                override var bar: Int {
                    get {
                        super.bar
                    }
                }
                override var baz: Bool {
                    get {
                        super.baz
                    }
                    set {
                        super.baz = newValue
                    }
                }
            }

            #endif
            """
        }
    }

    func testClassWithOptionalAndImplicitlyUnwrappedOptional() {
        assertMacro {
            """
            @AddSpy
            class SomeClass {
                var foo: String?
                var bar: Int!
            }
            """
        } expansion: {
            """
            class SomeClass {
                var foo: String?
                var bar: Int!
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo: String? {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }
                override var bar: Int! {
                    get {
                        super.bar
                    }
                    set {
                        super.bar = newValue
                    }
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
            class SomeClass {
                var foo = "Hello World"
                private var bar = 7
                private func baz() -> Bool {
                    return true
                }
            }
            """
        } expansion: {
            """
            class SomeClass {
                var foo = "Hello World"
                private var bar = 7
                private func baz() -> Bool {
                    return true
                }
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }
            }

            #endif
            """
        }
    }

    func testClassWithInit() {
        assertMacro {
            """
            @AddSpy
            class SomeClass {
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
            class SomeClass {
                let foo: String

                init(foo: String) {
                    self.foo = foo
                }

                func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo: String {
                    get {
                        super.foo
                    }
                }

                override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return super.bar()
                }

            }

            #endif
            """
        }
    }

    func testDoesNotSpyPrivateInit() {
        assertMacro {
            """
            @AddSpy
            class SomeClass {
                let foo: String

                private init(foo: String) {
                    self.foo = foo
                }

                func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            class SomeClass {
                let foo: String

                private init(foo: String) {
                    self.foo = foo
                }

                func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo: String {
                    get {
                        super.foo
                    }
                }

                override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return super.bar()
                }

            }

            #endif
            """
        }
    }

    func testFinalMembersAreNotSpied() {
        assertMacro {
            """
            @AddSpy
            class SomeClass {
                var foo = "Hello World"
                final func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            class SomeClass {
                var foo = "Hello World"
                final func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }
            }

            #endif
            """
        }
    }

    func testPrivateClass() {
        assertMacro {
            """
            @AddSpy
            private class SomeClass {
                var foo = "Hello World"

                func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            private class SomeClass {
                var foo = "Hello World"

                func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            final
            private class SpySomeClass: SomeClass, Spy {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }

                override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return super.bar()
                }

            }

            #endif
            """
        }
    }

    func testPublicClass() {
        assertMacro {
            """
            @AddSpy
            public class SomeClass {
                public var foo = "Hello World"

                public func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            public class SomeClass {
                public var foo = "Hello World"

                public func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            final
            public class SpySomeClass: SomeClass, Spy {

                public let blackBox = BlackBox(mockType: SpySomeClass.self)

                public override var foo {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }

                public override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return super.bar()
                }

            }

            #endif
            """
        }
    }

    func testUncheckedSendableClass() {
        assertMacro {
            """
            @AddSpy
            class SomeClass: @unchecked Sendable {
                var foo = "Hello World"

                func bar() -> Int {
                    return 42
                }
            }
            """
        } expansion: {
            """
            class SomeClass: @unchecked Sendable {
                var foo = "Hello World"

                func bar() -> Int {
                    return 42
                }
            }

            #if DEBUG

            final class SpySomeClass: SomeClass, Spy, @unchecked Sendable {

                let blackBox = BlackBox(mockType: SpySomeClass.self)

                override var foo {
                    get {
                        super.foo
                    }
                    set {
                        super.foo = newValue
                    }
                }

                override func bar() -> Int {
                    recordCall(returning: Int.self)
                    return super.bar()
                }

            }

            #endif
            """
        }
    }

}

#endif

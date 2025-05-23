//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

final class AddMockMacroExpansionProtocolTests: AddMockMacroExpansionTestCase {

    func testProtocol() {
        assertMacro {
            """
            @AddMock
            protocol SomeProtocol {
                func foo() throws -> String
                func bar(with paramOne: String) -> Int
                func baz(with paramOne: String, for paramTwo: String) -> Bool
                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String
                mutating func rab(paramOne: Bool)
            }
            """
        } expansion: {
            """
            protocol SomeProtocol {
                func foo() throws -> String
                func bar(with paramOne: String) -> Int
                func baz(with paramOne: String, for paramTwo: String) -> Bool
                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String
                mutating func rab(paramOne: Bool)
            }

            #if DEBUG

            final class MockSomeProtocol: SomeProtocol, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                func foo() throws -> String {
                    recordCall(returning: String.self)
                    return try throwingStubOutput()
                }

                func bar(with paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return stubOutput(for: paramOne)
                }

                func baz(with paramOne: String, for paramTwo: String) -> Bool {
                    recordCall(with: (paramOne, paramTwo), returning: Bool.self)
                    return stubOutput(for: (paramOne, paramTwo))
                }

                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String {
                    recordCall(with: (paramOne, paramTwo, paramThree), returning: String.self)
                    return try throwingStubOutput(for: (paramOne, paramTwo, paramThree))
                }

                func rab(paramOne: Bool) {
                    recordCall(with: paramOne)
                    return stubOutput(for: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testProtocolWithStaticMembers() {
        assertMacro {
            """
            @AddMock
            protocol SomeProtocol {
                var foo: String { get }
                static var bar: Int { get set }
                static var baz: Bool { get set }

                static func oof(paramOne: String) -> Int
            }
            """
        } expansion: {
            """
            protocol SomeProtocol {
                var foo: String { get }
                static var bar: Int { get set }
                static var baz: Bool { get set }

                static func oof(paramOne: String) -> Int
            }

            #if DEBUG

            final class MockSomeProtocol: SomeProtocol, Mock {

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
                static var bar: Int {
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

    func testProtocolWithGenericMethod() {
        assertMacro {
            """
            @AddMock
            protocol SomeProtocol {
                func foo<T>() -> T
            }
            """
        } expansion: {
            """
            protocol SomeProtocol {
                func foo<T>() -> T
            }

            #if DEBUG

            final class MockSomeProtocol: SomeProtocol, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                func foo<T>() -> T {
                    recordCall(returning: T.self)
                    return stubOutput()
                }

            }

            #endif
            """
        }
    }

    func testProtocolWithGenericMethodUsingWhereClause() {
        assertMacro {
            """
            @AddMock
            protocol SomeProtocol {
                func foo<T>() -> T where T: Equatable
            }
            """
        } expansion: {
            """
            protocol SomeProtocol {
                func foo<T>() -> T where T: Equatable
            }

            #if DEBUG

            final class MockSomeProtocol: SomeProtocol, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                func foo<T>() -> T where T: Equatable {
                    recordCall(returning: T.self)
                    return stubOutput()
                }

            }

            #endif
            """
        }
    }

    func testObjectiveCProtocol() {
        assertMacro {
            """
            @AddMock
            @objc protocol SomeProtocol {
                func foo1()
            }
            """
        } expansion: {
            """
            @objc protocol SomeProtocol {
                func foo1()
            }

            #if DEBUG

            @objc final class MockSomeProtocol: NSObject, SomeProtocol, Mock {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()

                func foo1() {
                    recordCall()
                    return stubOutput()
                }

            }

            #endif
            """
        }
    }

    func testGenericProtocol() {
        assertMacro {
            """
            @AddMock
            protocol SomeProtocol<T> {
                associatedtype T
                var foo: T
                func bar() -> T
            }
            """
        } expansion: {
            """
            protocol SomeProtocol<T> {
                associatedtype T
                var foo: T
                func bar() -> T
            }

            #if DEBUG

            final class MockSomeProtocol<T>: SomeProtocol, Mock {

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

    func testPublicProtocol() {
        assertMacro {
            """
            @AddMock
            public protocol SomeProtocol {
                var x: String
                func foo() throws -> String
                mutating func bar(paramOne: Bool)
                init(x: String)
            }
            """
        } expansion: {
            """
            public protocol SomeProtocol {
                var x: String
                func foo() throws -> String
                mutating func bar(paramOne: Bool)
                init(x: String)
            }

            #if DEBUG

            final
            public class MockSomeProtocol: SomeProtocol, Mock {

                public let blackBox = BlackBox()
                public let stubRegistry = StubRegistry()

                public var x: String {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                public init() {
                }

                @available(*, deprecated, message: "Use init() instead to initialize a mock") public init(x: String) {
                }

                public func foo() throws -> String {
                    recordCall(returning: String.self)
                    return try throwingStubOutput()
                }

                public func bar(paramOne: Bool) {
                    recordCall(with: paramOne)
                    return stubOutput(for: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testPublicProtocolWithoutInit() {
        assertMacro {
            """
            @AddMock
            public protocol SomeProtocol {
                var x: String
                func foo() throws -> String
                mutating func bar(paramOne: Bool)
            }
            """
        } expansion: {
            """
            public protocol SomeProtocol {
                var x: String
                func foo() throws -> String
                mutating func bar(paramOne: Bool)
            }

            #if DEBUG

            final
            public class MockSomeProtocol: SomeProtocol, Mock {

                public let blackBox = BlackBox()
                public let stubRegistry = StubRegistry()

                public var x: String {
                    get {
                        stubValue()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                public init() {
                }

                public func foo() throws -> String {
                    recordCall(returning: String.self)
                    return try throwingStubOutput()
                }

                public func bar(paramOne: Bool) {
                    recordCall(with: paramOne)
                    return stubOutput(for: paramOne)
                }

            }

            #endif
            """
        }
    }

}

#endif

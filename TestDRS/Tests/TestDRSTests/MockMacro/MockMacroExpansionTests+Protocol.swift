//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

extension MockMacroExpansionTests {

    func testMockMacro_WithProtocol() {
        assertMacro {
            """
            @Mock
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

            class MockSomeProtocol: SomeProtocol, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                func foo() throws -> String {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: try throwingStubOutput())
                }

                func bar(with paramOne: String) -> Int {
                    let callTime = Date()
                    return recordCall(
                        with: paramOne,
                        at: callTime,
                        returning: stubOutput(for: paramOne)
                    )
                }

                func baz(with paramOne: String, for paramTwo: String) -> Bool {
                    let callTime = Date()
                    return recordCall(
                        with: (paramOne, paramTwo),
                        at: callTime,
                        returning: stubOutput(for: (paramOne, paramTwo))
                    )
                }

                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String {
                    let callTime = Date()
                    return recordCall(
                        with: (paramOne, paramTwo, paramThree),
                        at: callTime,
                        returning: try throwingStubOutput(for: (paramOne, paramTwo, paramThree))
                    )
                }

                func rab(paramOne: Bool) {
                    let callTime = Date()
                    return recordCall(
                        with: paramOne,
                        at: callTime,
                        returning: Void()
                    )
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithProtocol_WithStaticMembers() {
        assertMacro {
            """
            @Mock
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

            class MockSomeProtocol: SomeProtocol, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                var foo: String {
                    get {
                        stubOutput()
                    }
                    set {
                        setStub(value: newValue)
                    }
                }

                static var bar: Int {
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

    func testMockMacro_WithProtocol_WithGenericMethod() {
        assertMacro {
            """
            @Mock
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

            class MockSomeProtocol: SomeProtocol, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                func foo<T>() -> T {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: stubOutput())
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithProtocol_WithGenericMethodUsingWhereClause() {
        assertMacro {
            """
            @Mock
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

            class MockSomeProtocol: SomeProtocol, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                func foo<T>() -> T where T: Equatable {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: stubOutput())
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithObjectiveCProtocol() {
        assertMacro {
            """
            @Mock
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

            @objc class MockSomeProtocol: NSObject, SomeProtocol, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

                func foo1() {
                    let callTime = Date()
                    return recordCall(at: callTime, returning: Void())
                }

            }

            #endif
            """
        }
    }

    func testMockMacro_WithGenericProtocol() {
        assertMacro {
            """
            @Mock
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

            class MockSomeProtocol<T>: SomeProtocol, Spy, StubProviding {

                let blackBox = BlackBox()
                let stubRegistry = StubRegistry()
                static let blackBox = BlackBox()
                static let stubRegistry = StubRegistry()

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

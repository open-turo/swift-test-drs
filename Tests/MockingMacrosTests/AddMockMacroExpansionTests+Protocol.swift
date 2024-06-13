//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(MockingMacros)

import MacroTesting
import XCTest

extension AddMockMacroExpansionTests {

    func testAddMockMacro_WithProtocol() {
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
            @AddMock
            protocol SomeProtocol {
                func foo() throws -> String
                func bar(with paramOne: String) -> Int
                func baz(with paramOne: String, for paramTwo: String) -> Bool
                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String
                mutating func rab(paramOne: Bool)
            }
            """
        }
    }

    func testAddMockMacro_WithProtocol_WithStaticMembers() {
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
            @AddMock
            protocol SomeProtocol {
                var foo: String { get }
                static var bar: Int { get set }
                static var baz: Bool { get set }

                static func oof(paramOne: String) -> Int
            }
            """
        }
    }

    func testAddMockMacro_WithProtocol_WithGenericMethod() {
        assertMacro {
            """
            @AddMock
            protocol SomeProtocol {
                func foo<T>() -> T
            }
            """
        } expansion: {
            """
            @AddMock
            protocol SomeProtocol {
                func foo<T>() -> T
            }
            """
        }
    }

    func testAddMockMacro_WithProtocol_WithGenericMethodUsingWhereClause() {
        assertMacro {
            """
            @AddMock
            protocol SomeProtocol {
                func foo<T>() -> T where T: Equatable
            }
            """
        } expansion: {
            """
            @AddMock
            protocol SomeProtocol {
                func foo<T>() -> T where T: Equatable
            }
            """
        }
    }

    func testAddMockMacro_WithObjectiveCProtocol() {
        assertMacro {
            """
            @AddMock
            @objc protocol SomeProtocol {
                func foo1()
            }
            """
        } expansion: {
            """
            @AddMock
            @objc protocol SomeProtocol {
                func foo1()
            }
            """
        }
    }

    func testAddMockMacro_WithGenericProtocol() {
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
            @AddMock
            protocol SomeProtocol<T> {
                associatedtype T
                var foo: T
                func bar() -> T
            }
            """
        }
    }

}

#endif

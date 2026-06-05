//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class AddSpyMacroExpansionProtocolTests: AddSpyMacroExpansionTestCase {

    func testProtocolWithGetOnlyProperty() {
        assertMacro {
            """
            @AddSpy
            protocol SomeProtocol {
                var name: String { get }
                func doSomething(value: String) -> Int
            }
            """
        } expansion: {
            """
            protocol SomeProtocol {
                var name: String { get }
                func doSomething(value: String) -> Int
            }

            #if DEBUG

            final class SpySomeProtocol<RealType: SomeProtocol>: SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                var name: String {
                    get {
                        real.name
                    }
                }

                init(real: RealType) {
                    self.real = real
                }

                func doSomething(value: String) -> Int {
                    recordCall(with: value, returning: Int.self)
                    return real.doSomething(value: value)
                }

            }

            #endif
            """
        }
    }

    func testProtocolWithGetSetProperty() {
        assertMacro {
            """
            @AddSpy
            protocol SomeProtocol {
                var name: String { get set }
            }
            """
        } expansion: {
            """
            protocol SomeProtocol {
                var name: String { get set }
            }

            #if DEBUG

            final class SpySomeProtocol<RealType: SomeProtocol>: SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                var name: String {
                    get {
                        real.name
                    }
                    set {
                        real.name = newValue
                    }
                }

                init(real: RealType) {
                    self.real = real
                }
            }

            #endif
            """
        }
    }

    func testProtocol() {
        assertMacro {
            """
            @AddSpy
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

            final class SpySomeProtocol<RealType: SomeProtocol>: SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                init(real: RealType) {
                    self.real = real
                }

                func foo() throws -> String {
                    recordCall(returning: String.self)
                    return try real.foo()
                }

                func bar(with paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return real.bar(with : paramOne)
                }

                func baz(with paramOne: String, for paramTwo: String) -> Bool {
                    recordCall(with: (paramOne, paramTwo), returning: Bool.self)
                    return real.baz(with : paramOne, for : paramTwo)
                }

                func oof(with paramOne: String, for paramTwo: String, paramThree: Int) throws -> String {
                    recordCall(with: (paramOne, paramTwo, paramThree), returning: String.self)
                    return try real.oof(with : paramOne, for : paramTwo, paramThree: paramThree)
                }

                func rab(paramOne: Bool) {
                    recordCall(with: paramOne)
                    real.rab(paramOne: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testProtocolWithStaticMembers() {
        assertMacro {
            """
            @AddSpy
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

            final class SpySomeProtocol<RealType: SomeProtocol>: SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                var foo: String {
                    get {
                        real.foo
                    }
                }
                static var bar: Int {
                    get {
                        RealType.bar
                    }
                    set {
                        RealType.bar = newValue
                    }
                }
                static var baz: Bool {
                    get {
                        RealType.baz
                    }
                    set {
                        RealType.baz = newValue
                    }
                }

                init(real: RealType) {
                    self.real = real
                }

                static func oof(paramOne: String) -> Int {
                    recordCall(with: paramOne, returning: Int.self)
                    return RealType.oof(paramOne: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testProtocolWithGenericMethod() {
        assertMacro {
            """
            @AddSpy
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

            final class SpySomeProtocol<RealType: SomeProtocol>: SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                init(real: RealType) {
                    self.real = real
                }

                func foo<T>() -> T {
                    recordCall(returning: T.self)
                    return real.foo()
                }

            }

            #endif
            """
        }
    }

    func testProtocolWithGenericMethodUsingWhereClause() {
        assertMacro {
            """
            @AddSpy
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

            final class SpySomeProtocol<RealType: SomeProtocol>: SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                init(real: RealType) {
                    self.real = real
                }

                func foo<T>() -> T where T: Equatable {
                    recordCall(returning: T.self)
                    return real.foo()
                }

            }

            #endif
            """
        }
    }

    func testObjectiveCProtocol() {
        assertMacro {
            """
            @AddSpy
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

            @objc final class SpySomeProtocol<RealType: SomeProtocol>: NSObject, SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                init(real: RealType) {
                    self.real = real
                }

                func foo1() {
                    recordCall()
                    real.foo1()
                }

            }

            #endif
            """
        }
    }

    func testObjectiveCProtocolWithInitializer() {
        assertMacro {
            """
            @AddSpy
            @objc protocol SomeProtocol {
                init()
                func foo()
            }
            """
        } expansion: {
            """
            @objc protocol SomeProtocol {
                init()
                func foo()
            }

            #if DEBUG

            @objc final class SpySomeProtocol<RealType: SomeProtocol>: NSObject, SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                init(real: RealType) {
                    self.real = real
                }

                func foo() {
                    recordCall()
                    real.foo()
                }

            }

            #endif
            """
        }
    }

    func testObjectiveCProtocolWithParameterizedInitializer() {
        assertMacro {
            """
            @AddSpy
            @objc protocol SomeProtocol {
                init(value: String)
                func foo()
            }
            """
        } expansion: {
            """
            @objc protocol SomeProtocol {
                init(value: String)
                func foo()
            }

            #if DEBUG

            @objc final class SpySomeProtocol<RealType: SomeProtocol>: NSObject, SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                init(real: RealType) {
                    self.real = real
                }

                func foo() {
                    recordCall()
                    real.foo()
                }

            }

            #endif
            """
        }
    }

    func testGenericProtocol() {
        assertMacro {
            """
            @AddSpy
            protocol SomeProtocol<T> {
                associatedtype T
                var foo: T { get set }
                func bar() -> T
            }
            """
        } expansion: {
            """
            protocol SomeProtocol<T> {
                associatedtype T
                var foo: T { get set }
                func bar() -> T
            }

            #if DEBUG

            final class SpySomeProtocol<RealType: SomeProtocol, T>: SomeProtocol, Spy {

                let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                var foo: T {
                    get {
                        real.foo
                    }
                    set {
                        real.foo = newValue
                    }
                }

                init(real: RealType) {
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

    func testPublicProtocol() {
        assertMacro {
            """
            @AddSpy
            public protocol SomeProtocol {
                var x: String { get set }
                func foo() throws -> String
                mutating func bar(paramOne: Bool)
                init(x: String)
            }
            """
        } expansion: {
            """
            public protocol SomeProtocol {
                var x: String { get set }
                func foo() throws -> String
                mutating func bar(paramOne: Bool)
                init(x: String)
            }

            #if DEBUG

            final
            public class SpySomeProtocol<RealType: SomeProtocol>: SomeProtocol, Spy {

                public let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                public var x: String {
                    get {
                        real.x
                    }
                    set {
                        real.x = newValue
                    }
                }

                public init(real: RealType) {
                    self.real = real
                }

                public func foo() throws -> String {
                    recordCall(returning: String.self)
                    return try real.foo()
                }

                public func bar(paramOne: Bool) {
                    recordCall(with: paramOne)
                    real.bar(paramOne: paramOne)
                }

            }

            #endif
            """
        }
    }

    func testPublicProtocolWithoutInit() {
        assertMacro {
            """
            @AddSpy
            public protocol SomeProtocol {
                var x: String { get set }
                func foo() throws -> String
                mutating func bar(paramOne: Bool)
            }
            """
        } expansion: {
            """
            public protocol SomeProtocol {
                var x: String { get set }
                func foo() throws -> String
                mutating func bar(paramOne: Bool)
            }

            #if DEBUG

            final
            public class SpySomeProtocol<RealType: SomeProtocol>: SomeProtocol, Spy {

                public let blackBox = BlackBox(mockType: SpySomeProtocol.self)
                private let real: RealType

                public var x: String {
                    get {
                        real.x
                    }
                    set {
                        real.x = newValue
                    }
                }

                public init(real: RealType) {
                    self.real = real
                }

                public func foo() throws -> String {
                    recordCall(returning: String.self)
                    return try real.foo()
                }

                public func bar(paramOne: Bool) {
                    recordCall(with: paramOne)
                    real.bar(paramOne: paramOne)
                }

            }

            #endif
            """
        }
    }

}

#endif

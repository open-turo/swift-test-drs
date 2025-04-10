//
// Created on 1/24/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

final class AddMockMacroExpansionDiagnosticTests: AddMockMacroExpansionTestCase {

    func testEnumProducesDiagnostic() {
        assertMacro {
            """
            @AddMock
            enum SomeEnum {
                case foo
                case bar
            }
            """
        } diagnostics: {
            """
            @AddMock
            ┬───────
            ╰─ 🛑 @AddMock can only be applied to protocols, classes, and structs
            enum SomeEnum {
                case foo
                case bar
            }
            """
        }
    }

    func testActorProducesDiagnostic() {
        assertMacro {
            """
            @AddMock
            actor SomeActor {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        } diagnostics: {
            """
            @AddMock
            ┬───────
            ╰─ 🛑 @AddMock can only be applied to protocols, classes, and structs
            actor SomeActor {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testFinalClassProducesDiagnostic() {
        assertMacro {
            """
            @AddMock
            final class SomeClass {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        } diagnostics: {
            """
            @AddMock
            ╰─ 🛑 @AddMock can't be applied to final classes as they can not be subclassed to produce a mock.
            final class SomeClass {
                var foo = "Hello World"
                func bar() {
                    // fatalError("Unimplemented")
                }
            }
            """
        }
    }

    func testActorConstrainedProtocolProducesDiagnostic() {
        assertMacro {
            """
            @AddMock
            protocol SomeProtocol: Actor {
                var foo: String { get set }
                func bar()
            }
            """
        } diagnostics: {
            """
            @AddMock
            ┬───────
            ╰─ 🛑 @AddMock can't be applied to actor-constrained protocols. Consider using a more general constraint like Sendable to allow for class-based mocks.
            protocol SomeProtocol: Actor {
                var foo: String { get set }
                func bar()
            }
            """
        }
    }

}

#endif

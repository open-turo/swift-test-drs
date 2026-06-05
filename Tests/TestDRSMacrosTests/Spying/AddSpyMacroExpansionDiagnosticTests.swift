//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import XCTest

final class AddSpyMacroExpansionDiagnosticTests: AddSpyMacroExpansionTestCase {

    func testEnumProducesDiagnostic() {
        assertMacro {
            """
            @AddSpy
            enum SomeEnum {
                case foo
                case bar
            }
            """
        } diagnostics: {
            """
            @AddSpy
            ┬──────
            ╰─ 🛑 @AddSpy can only be applied to protocols, classes, and structs
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
            @AddSpy
            actor SomeActor {
                var foo = "Hello World"
                func bar() {
                    // Implementation
                }
            }
            """
        } diagnostics: {
            """
            @AddSpy
            ┬──────
            ╰─ 🛑 @AddSpy can only be applied to protocols, classes, and structs
            actor SomeActor {
                var foo = "Hello World"
                func bar() {
                    // Implementation
                }
            }
            """
        }
    }

    func testFinalClassProducesDiagnostic() {
        assertMacro {
            """
            @AddSpy
            final class SomeClass {
                var foo = "Hello World"
                func bar() {
                    // Implementation
                }
            }
            """
        } diagnostics: {
            """
            @AddSpy
            ╰─ 🛑 @AddSpy can't be applied to final classes as they can not be subclassed to produce a spy.
            final class SomeClass {
                var foo = "Hello World"
                func bar() {
                    // Implementation
                }
            }
            """
        }
    }

    func testActorConstrainedProtocolProducesDiagnostic() {
        assertMacro {
            """
            @AddSpy
            protocol SomeProtocol: Actor {
                var foo: String { get set }
                func bar()
            }
            """
        } diagnostics: {
            """
            @AddSpy
            ┬──────
            ╰─ 🛑 @AddSpy can't be applied to actor-constrained protocols. Consider using a more general constraint like Sendable to allow for class-based spies.
            protocol SomeProtocol: Actor {
                var foo: String { get set }
                func bar()
            }
            """
        }
    }

}

#endif

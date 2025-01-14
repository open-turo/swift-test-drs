//
// Created on 1/13/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
@testable import TestDRSMacros
import XCTest

final class ConfirmationOfCallMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: [
            "confirmationOfCall": ConfirmationOfCallMacro.self,
        ]) {
            super.invokeTest()
        }
    }

    func testConfirmationOfCallMacro_WithNoMemberAccess() {
        assertMacro {
            """
            await #confirmationOfCall(to: foo)
            """
        } expansion: {
            """
            await confirmationOfCall(to: foo, withSignature: "foo")
            """
        }
    }

    func testConfirmationOfCallMacro_WithMemberAccess() {
        assertMacro {
            """
            await #confirmationOfCall(to: mock.foo)
            """
        } expansion: {
            """
            await mock.confirmationOfCall(to: mock.foo, withSignature: "foo")
            """
        }
    }

    func testConfirmationOfCallMacro_WithNestedMemberAccess() {
        assertMacro {
            """
            await #confirmationOfCall(to: base.mock.foo)
            """
        } expansion: {
            """
            await base.mock.confirmationOfCall(to: base.mock.foo, withSignature: "foo")
            """
        }
    }

    func testConfirmationOfCallMacro_WithSingleArgument() {
        assertMacro {
            """
            await #confirmationOfCall(to: mock.foo(paramOne:))
            """
        } expansion: {
            """
            await mock.confirmationOfCall(to: mock.foo(paramOne:), withSignature: "foo(paramOne:)")
            """
        }
    }

    func testConfirmationOfCallMacro_WithMultipleArguments() {
        assertMacro {
            """
            await #confirmationOfCall(to: mock.foo(_:paramTwo:))
            """
        } expansion: {
            """
            await mock.confirmationOfCall(to: mock.foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)")
            """
        }
    }

    func testConfirmationOfCallMacro_WithExpectedInput() {
        assertMacro {
            """
            await #confirmationOfCall(to: mock.foo(paramOne:), with: "Hello World")
            """
        } expansion: {
            """
            await mock.confirmationOfCall(
                to: mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World"
            )
            """
        }
    }

    func testConfirmationOfCallMacro_WithExpectedInputAndOutputType() {
        assertMacro {
            """
            await #confirmationOfCall(to: mock.foo(paramOne:), with: "Hello World", returning: String.self)
            """
        } expansion: {
            """
            await mock.confirmationOfCall(
                to: mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World",
                returning: String.self
            )
            """
        }
    }

    func testConfirmationOfCallMacro_WithTimeLimit() {
        assertMacro {
            """
            await #confirmationOfCall(to: mock.foo, timeLimit: .milliseconds(1))
            """
        } expansion: {
            """
            await mock.confirmationOfCall(
                to: mock.foo,
                withSignature: "foo",
                timeLimit: .milliseconds(1)
            )
            """
        }
    }

}

#endif

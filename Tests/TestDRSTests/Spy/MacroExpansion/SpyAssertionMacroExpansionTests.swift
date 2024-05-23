//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
@testable import TestDRSMacros
import XCTest

final class SpyAssertionMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: [
            "assertWasCalled": AssertWasCalledMacro.self,
            "assertWasNotCalled": AssertWasNotCalledMacro.self
        ]) {
            super.invokeTest()
        }
    }

    // MARK: - #assertWasCalled

    func testAssertWasCalledMacro_WithNoMemberAccess() {
        assertMacro {
            """
            #assertWasCalled(foo)
            """
        } expansion: {
            """
            assertWasCalled(foo, withSignature: "foo")
            """
        }
    }

    func testAssertWasCalledMacro_WithMemberAccess() {
        assertMacro {
            """
            #assertWasCalled(mock.foo)
            """
        } expansion: {
            """
            mock.assertWasCalled(mock.foo, withSignature: "foo")
            """
        }
    }

    func testAssertWasCalledMacro_WithNestedMemberAccess() {
        assertMacro {
            """
            #assertWasCalled(base.mock.foo)
            """
        } expansion: {
            """
            base.mock.assertWasCalled(base.mock.foo, withSignature: "foo")
            """
        }
    }

    func testAssertWasCalledMacro_WithSingleArgument() {
        assertMacro {
            """
            #assertWasCalled(mock.foo(paramOne:))
            """
        } expansion: {
            """
            mock.assertWasCalled(mock.foo(paramOne:), withSignature: "foo(paramOne:)")
            """
        }
    }

    func testAssertWasCalledMacro__WithMultipleArguments() {
        assertMacro {
            """
            #assertWasCalled(mock.foo(_:paramTwo:))
            """
        } expansion: {
            """
            mock.assertWasCalled(mock.foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)")
            """
        }
    }

    func testAssertWasCalledMacro_WithExpectedInput() {
        assertMacro {
            """
            #assertWasCalled(mock.foo(paramOne:), with: "Hello World")
            """
        } expansion: {
            """
            mock.assertWasCalled(
                mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World"
            )
            """
        }
    }

    func testAssertWasCalledMacro_WithExpectedInputAndOutputType() {
        assertMacro {
            """
            #assertWasCalled(mock.foo(paramOne:), with: "Hello World", returning: String.self)
            """
        } expansion: {
            """
            mock.assertWasCalled(
                mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World",
                returning: String.self
            )
            """
        }
    }

    func testAssertWasCalledMacro_WithStaticFunction() {
        assertMacro {
            """
            #assertWasCalled(Mock.foo)
            """
        } expansion: {
            """
            Mock.assertStaticFunctionWasCalled(Mock.foo, withSignature: "foo")
            """
        }
    }

    func testAssertWasCalledMacro_WithStaticFunction_WithExpectedInput() {
        assertMacro {
            """
            #assertWasCalled(Mock.foo(paramOne:), with: "Hello World")
            """
        } expansion: {
            """
            Mock.assertStaticFunctionWasCalled(
                Mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World"
            )
            """
        }
    }

    // MARK: - #assertWasNotCalled

    func testAssertWasNotCalledMacro() {
        assertMacro {
            """
            #assertWasNotCalled(mock.foo)
            """
        } expansion: {
            """
            mock.assertWasNotCalled(mock.foo, withSignature: "foo")
            """
        }
    }

    func testAssertWasNotCalledMacro_WithStaticFunction() {
        assertMacro {
            """
            #assertWasNotCalled(Mock.foo)
            """
        } expansion: {
            """
            Mock.assertStaticFunctionWasNotCalled(Mock.foo, withSignature: "foo")
            """
        }
    }

}

#endif

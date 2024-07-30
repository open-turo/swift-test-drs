//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
@testable import TestDRSMacros
import XCTest

final class SwiftTestingExpectationMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: [
            "expectWasCalled": ExpectWasCalledMacro.self,
            "expectWasNotCalled": ExpectWasNotCalledMacro.self
        ]) {
            super.invokeTest()
        }
    }

    // MARK: - #expectWasCalled

    func testExpectWasCalledMacro_WithNoMemberAccess() {
        assertMacro {
            """
            #expectWasCalled(foo)
            """
        } expansion: {
            """
            expectWasCalled(foo, withSignature: "foo")
            """
        }
    }

    func testExpectWasCalledMacro_WithMemberAccess() {
        assertMacro {
            """
            #expectWasCalled(mock.foo)
            """
        } expansion: {
            """
            mock.expectWasCalled(mock.foo, withSignature: "foo")
            """
        }
    }

    func testExpectWasCalledMacro_WithNestedMemberAccess() {
        assertMacro {
            """
            #expectWasCalled(base.mock.foo)
            """
        } expansion: {
            """
            base.mock.expectWasCalled(base.mock.foo, withSignature: "foo")
            """
        }
    }

    func testExpectWasCalledMacro_WithSingleArgument() {
        assertMacro {
            """
            #expectWasCalled(mock.foo(paramOne:))
            """
        } expansion: {
            """
            mock.expectWasCalled(mock.foo(paramOne:), withSignature: "foo(paramOne:)")
            """
        }
    }

    func testExpectWasCalledMacro__WithMultipleArguments() {
        assertMacro {
            """
            #expectWasCalled(mock.foo(_:paramTwo:))
            """
        } expansion: {
            """
            mock.expectWasCalled(mock.foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)")
            """
        }
    }

    func testExpectWasCalledMacro_WithExpectedInput() {
        assertMacro {
            """
            #expectWasCalled(mock.foo(paramOne:), with: "Hello World")
            """
        } expansion: {
            """
            mock.expectWasCalled(
                mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World"
            )
            """
        }
    }

    func testExpectWasCalledMacro_WithExpectedInputAndOutputType() {
        assertMacro {
            """
            #expectWasCalled(mock.foo(paramOne:), with: "Hello World", returning: String.self)
            """
        } expansion: {
            """
            mock.expectWasCalled(
                mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World",
                returning: String.self
            )
            """
        }
    }

    func testExpectWasCalledMacro_WithStaticFunction() {
        assertMacro {
            """
            #expectWasCalled(Mock.foo)
            """
        } expansion: {
            """
            Mock.expectStaticFunctionWasCalled(Mock.foo, withSignature: "foo")
            """
        }
    }

    func testExpectWasCalledMacro_WithStaticFunction_WithExpectedInput() {
        assertMacro {
            """
            #expectWasCalled(Mock.foo(paramOne:), with: "Hello World")
            """
        } expansion: {
            """
            Mock.expectStaticFunctionWasCalled(
                Mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World"
            )
            """
        }
    }

    // MARK: - #expectWasNotCalled

    func testExpectWasNotCalledMacro() {
        assertMacro {
            """
            #expectWasNotCalled(mock.foo)
            """
        } expansion: {
            """
            mock.expectWasNotCalled(mock.foo, withSignature: "foo")
            """
        }
    }

    func testExpectWasNotCalledMacro_WithStaticFunction() {
        assertMacro {
            """
            #expectWasNotCalled(Mock.foo)
            """
        } expansion: {
            """
            Mock.expectStaticFunctionWasNotCalled(Mock.foo, withSignature: "foo")
            """
        }
    }

}

#endif

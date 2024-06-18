//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
@testable import TestDRSMacros
import XCTest

final class XCTestExpectationMacroExpansionTests: XCTestCase {

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
            expectWasCalled(
                foo,
                withSignature: "foo",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
            )
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
            mock.expectWasCalled(
                mock.foo,
                withSignature: "foo",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
            )
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
            base.mock.expectWasCalled(
                base.mock.foo,
                withSignature: "foo",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
            )
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
            mock.expectWasCalled(
                mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
            )
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
            mock.expectWasCalled(
                mock.foo(_:paramTwo:),
                withSignature: "foo(_:paramTwo:)",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
            )
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
            mock.expectWasCalled(
                mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
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
            mock.expectWasCalled(
                mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World",
                returning: String.self,
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
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
            Mock.expectStaticFunctionWasCalled(
                Mock.foo,
                withSignature: "foo",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
            )
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
            Mock.expectStaticFunctionWasCalled(
                Mock.foo(paramOne:),
                withSignature: "foo(paramOne:)",
                expectedInput: "Hello World",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
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
            mock.expectWasNotCalled(
                mock.foo,
                withSignature: "foo",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
            )
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
            Mock.expectStaticFunctionWasNotCalled(
                Mock.foo,
                withSignature: "foo",
                reportFailure: { message, location in
                    XCTFail(message, file: location.xctFile, line: location.xctLine)
                }
            )
            """
        }
    }

}

#endif

//
// Created on 5/20/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Expectations
import SharedTesting
import TestDRSCore
import XCTest

final class SpyAssertionsTests: SpyTestCase {

    private let file = #fileID.components(separatedBy: "/").last!
    private var line = 0

    // MARK: - assertWasCalled

    func testAssertWasCalled_WithoutCalling() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - No calls to "foo()" were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(foo, withSignature: "foo()", taking: Void.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - No calls to "foo()" were recorded
                """
            }
        )
    }

    func testAssertWasCalled_WithNoParameters() {
        foo()
        assertWasCalled(foo, withSignature: "foo()", taking: Void.self)
    }

    func testAssertWasCalled_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "World")
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 1)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 2)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Double.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - No calls to "zab(paramOne:)" with input type Double and output type Double were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 1.0)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - No calls to "zab(paramOne:)" with input type Double and output type Double were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: false)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -false
                +true
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Goodbye")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -Goodbye
                +Hello
                +World
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -4
                +1
                +2
                +3
                """
            }
        )
    }

    func testAssertWasCalled_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: false, paramTwo: nil, paramThree: nil)

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")
        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: false, Int?.none, String?.none)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "rab(paramOne:paramTwo:paramThree:)" was not called with expected input (-), but was called with other input (+):

                -(true, Optional(2), Optional("Hello"))
                +(true, Optional(1), Optional("Hello"))
                +(false, nil, nil)
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, Int?.none, String?.none)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "rab(paramOne:paramTwo:paramThree:)" was not called with expected input (-), but was called with other input (+):

                -(true, nil, nil)
                +(true, Optional(1), Optional("Hello"))
                +(false, nil, nil)
                """
            }
        )
    }

    // MARK: - assertWasNotCalled

    func testAssertWasNotCalled_WithoutCalling() {
        assertWasNotCalled(foo, withSignature: "foo()")
        assertWasNotCalled(bar(paramOne:), withSignature: "bar(paramOne:)")
    }

    func testAssertWasNotCalled_WithCall() {
        foo()

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasNotCalled(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - 1 calls to "foo()" with input type () and output type () were recorded
                """
            }
        )
    }

    func testAssertWasNotCalled_WithDifferentInputAndOutputTypes() {
        zab(paramOne: true)
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 1.0)

        assertWasNotCalled(zab(paramOne:), withSignature: "zab(paramOne:)", returning: String.self)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasNotCalled(zab(paramOne:), withSignature: "zab(paramOne:)", returning: Int.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - 2 calls to "zab(paramOne:)" with input type Int and output type Int were recorded
                """
            }
        )
    }

}

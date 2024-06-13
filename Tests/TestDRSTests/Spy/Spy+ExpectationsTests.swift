//
// Created on 5/20/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class SpyExpectationsTests: SpyTestCase {

    private let file = #fileID.components(separatedBy: "/").last!
    private var line = 0

    // MARK: - expectWasCalled

    func testExpectWasCalled_WithoutCalling() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to "foo()" were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(foo, withSignature: "foo()", taking: Void.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to "foo()" were recorded
                """
            }
        )
    }

    func testExpectWasCalled_WithNoParameters() {
        foo()
        expectWasCalled(foo, withSignature: "foo()", taking: Void.self)
    }

    func testExpectWasCalled_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)
        expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
        expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "World")
        expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 1)
        expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 2)
        expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Double.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to "zab(paramOne:)" with input type Double and output type Double were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 1.0)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to "zab(paramOne:)" with input type Double and output type Double were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: false)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -false
                +true
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Goodbye")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -Goodbye
                +Hello
                +World
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -4
                +1
                +2
                +3
                """
            }
        )
    }

    func testExpectWasCalled_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: false, paramTwo: nil, paramThree: nil)

        expectWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")
        expectWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: false, Int?.none, String?.none)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): "rab(paramOne:paramTwo:paramThree:)" was not called with expected input (-), but was called with other input (+):

                -(true, Optional(2), Optional("Hello"))
                +(true, Optional(1), Optional("Hello"))
                +(false, nil, nil)
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, Int?.none, String?.none)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): "rab(paramOne:paramTwo:paramThree:)" was not called with expected input (-), but was called with other input (+):

                -(true, nil, nil)
                +(true, Optional(1), Optional("Hello"))
                +(false, nil, nil)
                """
            }
        )
    }

    // MARK: - expectWasNotCalled

    func testExpectWasNotCalled_WithoutCalling() {
        expectWasNotCalled(foo, withSignature: "foo()")
        expectWasNotCalled(bar(paramOne:), withSignature: "bar(paramOne:)")
    }

    func testExpectWasNotCalled_WithCall() {
        foo()

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasNotCalled(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): 1 calls to "foo()" with input type () and output type () were recorded
                """
            }
        )
    }

    func testExpectWasNotCalled_WithDifferentInputAndOutputTypes() {
        zab(paramOne: true)
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 1.0)

        expectWasNotCalled(zab(paramOne:), withSignature: "zab(paramOne:)", returning: String.self)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                expectWasNotCalled(zab(paramOne:), withSignature: "zab(paramOne:)", returning: Int.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): 2 calls to "zab(paramOne:)" with input type Int and output type Int were recorded
                """
            }
        )
    }

}

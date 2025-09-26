//
// Created on 5/20/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class SpyExpectationsTests: XCTestCase {

    private let file = #fileID.components(separatedBy: "/").last!
    private var line = 0

    private let spy = TestSpy()

    // MARK: - expectWasCalled

    func testExpectWasCalled_WithoutCalling() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                spy.expectWasCalled(spy.foo, withSignature: "foo()")
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
                spy.expectWasCalled(spy.foo, withSignature: "foo()", taking: Void.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - No calls to "foo()" were recorded
                """
            }
        )
    }

    func testExpectWasCalled_WithNoParameters() {
        spy.foo()
        spy.expectWasCalled(spy.foo, withSignature: "foo()", taking: Void.self)
    }

    func testExpectWasCalled_WithDifferentParameterTypes() {
        spy.zab(paramOne: true)
        spy.zab(paramOne: "Hello")
        spy.zab(paramOne: "World")
        spy.zab(paramOne: 1)
        spy.zab(paramOne: 2)
        spy.zab(paramOne: 3)

        spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true, mode: .nonExclusive)
        spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello", mode: .nonExclusive)
        spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "World", mode: .nonExclusive)
        spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 1, mode: .nonExclusive)
        spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 2, mode: .nonExclusive)
        spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 3, mode: .nonExclusive)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", taking: Double.self, mode: .nonExclusive)
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
                spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 1.0, mode: .nonExclusive)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -1.0
                +true
                +Hello
                +World
                +1
                +2
                +3
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: false, mode: .nonExclusive)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -false
                +true
                +Hello
                +World
                +1
                +2
                +3
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Goodbye", mode: .nonExclusive)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -Goodbye
                +true
                +Hello
                +World
                +1
                +2
                +3
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 4, mode: .nonExclusive)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - "zab(paramOne:)" was not called with expected input (-), but was called with other input (+):

                -4
                +true
                +Hello
                +World
                +1
                +2
                +3
                """
            }
        )
    }

    func testExpectWasCalled_WithMultipleParameters() {
        spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        spy.rab(paramOne: false, paramTwo: nil, paramThree: nil)

        spy.expectWasCalled(spy.rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello", mode: .nonExclusive)
        spy.expectWasCalled(spy.rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: false, Int?.none, String?.none, mode: .nonExclusive)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                spy.expectWasCalled(spy.rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
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
                spy.expectWasCalled(spy.rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, Int?.none, String?.none)
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

    // MARK: - expectWasNotCalled

    func testExpectWasNotCalled_WithoutCalling() {
        spy.expectWasNotCalled(spy.foo, withSignature: "foo()")
        spy.expectWasNotCalled(spy.bar(paramOne:), withSignature: "bar(paramOne:)")
    }

    func testExpectWasNotCalled_WithCall() {
        spy.foo()

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                spy.expectWasNotCalled(spy.foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - 1 calls to "foo()" with input type () and output type () were recorded
                """
            }
        )
    }

    func testExpectWasNotCalled_WithDifferentInputAndOutputTypes() {
        spy.zab(paramOne: true)
        spy.zab(paramOne: 1)
        spy.zab(paramOne: 2)
        spy.zab(paramOne: 1.0)

        spy.expectWasNotCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", returning: String.self)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                spy.expectWasNotCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", returning: Int.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - 2 calls to "zab(paramOne:)" with input type Int and output type Int were recorded
                """
            }
        )
    }

    func testExpectWasCalled_ShowsNonExclusiveHint() {
        spy.zab(paramOne: true)
        spy.zab(paramOne: "Hello")
        spy.zab(paramOne: 42)

        _ = XCTExpectFailure(
            failingBlock: {
                spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true, mode: .exclusive)
            },
            issueMatcher: { issue in
                issue.description.contains("To ignore non-matching calls, use ExpectedCallMode.nonExclusive.")
            }
        )
    }

}

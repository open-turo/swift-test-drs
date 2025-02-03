//
// Created on 5/20/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class ExpectWasCalledResultTests: XCTestCase {

    private let file = #fileID.components(separatedBy: "/").last!
    private var line = 0
    private let spy = TestSpy()

    // MARK: - getMatchingCall() {

    func testGetMatchingCall_ThrowsErrorWhenNoCalls() throws {
        do {
            XCTExpectFailure()
            _ = try spy.expectWasCalled(spy.foo, withSignature: "foo()")
                .exactlyOnce()
                .getMatchingCall()
            XCTFail("Expected ExpectWasCalledResultError")
        } catch let error as ExpectWasCalledResultError {
            switch error {
            case .noCalls:
                break // Expected error
            }
        } catch {
            XCTFail("Expected ExpectWasCalledResultError")
        }
    }

    func testGetMatchingCall_GetstMatchingCall() throws {
        spy.zab(paramOne: "Hello")
        let callToZab = try spy.expectWasCalled(
            spy.zab(paramOne:),
            withSignature: "zab(paramOne:)",
            returning: String.self
        ).exactlyOnce()
            .getMatchingCall()

        XCTAssertEqual(callToZab.input, "Hello")
    }

    // MARK: - getFirstMatchingCall()

    func testGetFirstMatchingCall_ThrowsErrorWhenNoCalls() throws {
        do {
            XCTExpectFailure()
            _ = try spy.expectWasCalled(spy.foo, withSignature: "foo()")
                .getFirstMatchingCall()
            XCTFail("Expected ExpectWasCalledResultError")
        } catch let error as ExpectWasCalledResultError {
            switch error {
            case .noCalls:
                break // Expected error
            }
        } catch {
            XCTFail("Expected ExpectWasCalledResultError")
        }
    }

    func testGetFirstMatchingCall_GetsFirstMatchingCall() throws {
        spy.zab(paramOne: "Hello")
        spy.zab(paramOne: "World")

        let callToZab = try spy.expectWasCalled(
            spy.zab(paramOne:),
            withSignature: "zab(paramOne:)",
            returning: String.self
        ).getFirstMatchingCall()

        XCTAssertEqual(callToZab.input, "Hello")
    }

    // MARK: - getLastMatchingCall()

    func testGetLastMatchingCall_ThrowsErrorWhenNoCalls() throws {
        do {
            XCTExpectFailure()
            _ = try spy.expectWasCalled(spy.foo, withSignature: "foo()")
                .getLastMatchingCall()
            XCTFail("Expected ExpectWasCalledResultError")
        } catch let error as ExpectWasCalledResultError {
            switch error {
            case .noCalls:
                break // Expected error
            }
        } catch {
            XCTFail("Expected ExpectWasCalledResultError")
        }
    }

    func testGetLastMatchingCall_GetsLastMatchingCall() throws {
        spy.zab(paramOne: "Hello")
        spy.zab(paramOne: "World")

        let callToZab = try spy.expectWasCalled(
            spy.zab(paramOne:),
            withSignature: "zab(paramOne:)",
            returning: String.self
        ).getLastMatchingCall()

        XCTAssertEqual(callToZab.input, "World")
    }

    // MARK: - exactlyOnce()

    func testExactlyOnce_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callToFoo = spy.expectWasCalled(spy.foo, withSignature: "foo()")
                    .exactlyOnce()
                    .matchingCall

                XCTAssertNil(callToFoo)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - No calls to "foo()" were recorded
                """
            }
        )
    }

    func testExactlyOnce_WithSingleCall() {
        spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        let callToRab = spy.expectWasCalled(
            spy.rab(paramOne:paramTwo:paramThree:),
            withSignature: "rab(paramOne:paramTwo:paramThree:)",
            expectedInput: true, 1, "Hello"
        ).exactlyOnce()
            .matchingCall

        XCTAssertNotNil(callToRab)
    }

    func testExactlyOnce_WithMultipleCalls() {
        spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        XCTExpectFailure(
            failingBlock: {
                line = #line + 6
                let callToRab = spy.expectWasCalled(
                    spy.rab(paramOne:paramTwo:paramThree:),
                    withSignature: "rab(paramOne:paramTwo:paramThree:)",
                    expectedInput: true, 1, "Hello"
                )
                .exactlyOnce()
                .matchingCall

                XCTAssertNotNil(callToRab)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - Expected "rab(paramOne:paramTwo:paramThree:)" to be called exactly once as specified, but 2 calls were recorded
                """
            }
        )
    }

    // MARK: - occurring(times:)

    func testOccurringTimes_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToFoo = spy.expectWasCalled(spy.foo, withSignature: "foo()")
                    .occurring(times: 1)
                    .matchingCalls

                XCTAssertTrue(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - No calls to "foo()" were recorded
                """
            }
        )
    }

    func testOccurringTimes_WithMultipleCalls() {
        spy.foo()
        spy.foo()
        spy.foo()

        let callsToFoo = spy.expectWasCalled(spy.foo, withSignature: "foo()")
            .occurring(times: 3)
            .matchingCalls

        XCTAssertEqual(callsToFoo.count, 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = spy.expectWasCalled(spy.foo, withSignature: "foo()")
                    .occurring(times: 1)
                    .matchingCalls

                XCTAssertFalse(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - Expected "foo()" to be called as specified 1 times, but 3 calls were recorded
                """
            }
        )
    }

    func testOccurringTimes_WithGenericParameter_WithMultipleCalls() {
        spy.zab(paramOne: true)
        spy.zab(paramOne: "Hello")
        spy.zab(paramOne: "World")
        spy.zab(paramOne: 1)
        spy.zab(paramOne: 2)
        spy.zab(paramOne: 3)

        spy.expectWasCalled(
            spy.zab(paramOne:),
            withSignature: "zab(paramOne:)",
            taking: Bool.self,
            mode: .nonExclusive
        ).occurring(times: 1)
        spy.expectWasCalled(
            spy.zab(paramOne:),
            withSignature: "zab(paramOne:)",
            taking: String.self,
            mode: .nonExclusive
        ).occurring(times: 2)
        spy.expectWasCalled(
            spy.zab(paramOne:),
            withSignature: "zab(paramOne:)",
            taking: Int.self,
            mode: .nonExclusive
        ).occurring(times: 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                spy.expectWasCalled(spy.zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, mode: .nonExclusive)
                    .occurring(times: 4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - Expected "zab(paramOne:)" to be called as specified 4 times, but 1 calls were recorded
                """
            }
        )
    }

    // MARK: - occurringWithin(times:)

    func testOccurringTimesWithin_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToFoo = spy.expectWasCalled(spy.foo, withSignature: "foo()")
                    .occurringWithin(times: 0 ... 5)
                    .matchingCalls

                XCTAssertTrue(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - No calls to "foo()" were recorded
                """
            }
        )
    }

    func testOccurringTimesWithin_WithMultipleCalls() {
        spy.foo()
        spy.foo()
        spy.foo()

        spy.expectWasCalled(spy.foo, withSignature: "foo()")
            .occurringWithin(times: 2 ... 3)

        spy.expectWasCalled(spy.foo, withSignature: "foo()")
            .occurringWithin(times: 3...)

        let callsToFoo = spy.expectWasCalled(spy.foo, withSignature: "foo()")
            .occurringWithin(times: 2 ..< 4)
            .matchingCalls

        XCTAssertEqual(callsToFoo.count, 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = spy.expectWasCalled(spy.foo, withSignature: "foo()")
                    .occurringWithin(times: 0 ... 2)
                    .matchingCalls

                XCTAssertFalse(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - Expected "foo()" to be called as specified within 0...2 times, but 3 calls were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = spy.expectWasCalled(spy.foo, withSignature: "foo()")
                    .occurringWithin(times: 4...)
                    .matchingCalls

                XCTAssertFalse(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): failed - Expected "foo()" to be called as specified at least 4 times, but 3 calls were recorded
                """
            }
        )
    }

}

//
// Created on 5/20/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class AssertWasCalledResultTests: SpyTestCase {

    private let file = #fileID.components(separatedBy: "/").last!
    private var line = 0

    // MARK: - getMatchingCall() {

    func testGetMatchingCall_ThrowsErrorWhenNoCalls() throws {
        do {
            XCTExpectFailure()
            _ = try assertWasCalled(foo, withSignature: "foo()")
                .exactlyOnce()
                .getMatchingCall()
            XCTFail("Expected AssertWasCalledResultError")
        } catch let error as AssertWasCalledResultError {
            switch error {
            case .noCalls:
                break // Expected error
            }
        } catch {
            XCTFail("Expected AssertWasCalledResultError")
        }
    }

    func testGetMatchingCall_GetstMatchingCall() throws {
        zab(paramOne: "Hello")
        let callToZab = try assertWasCalled(
            zab(paramOne:),
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
            _ = try assertWasCalled(foo, withSignature: "foo()")
                .getFirstMatchingCall()
            XCTFail("Expected AssertWasCalledResultError")
        } catch let error as AssertWasCalledResultError {
            switch error {
            case .noCalls:
                break // Expected error
            }
        } catch {
            XCTFail("Expected AssertWasCalledResultError")
        }
    }

    func testGetFirstMatchingCall_GetsFirstMatchingCall() throws {
        zab(paramOne: "Hello")
        zab(paramOne: "World")

        let callToZab = try assertWasCalled(
            zab(paramOne:),
            withSignature: "zab(paramOne:)",
            returning: String.self
        ).getFirstMatchingCall()

        XCTAssertEqual(callToZab.input, "Hello")
    }

    // MARK: - getLastMatchingCall()

    func testGetLastMatchingCall_ThrowsErrorWhenNoCalls() throws {
        do {
            XCTExpectFailure()
            _ = try assertWasCalled(foo, withSignature: "foo()")
                .getLastMatchingCall()
            XCTFail("Expected AssertWasCalledResultError")
        } catch let error as AssertWasCalledResultError {
            switch error {
            case .noCalls:
                break // Expected error
            }
        } catch {
            XCTFail("Expected AssertWasCalledResultError")
        }
    }

    func testGetLastMatchingCall_GetsLastMatchingCall() throws {
        zab(paramOne: "Hello")
        zab(paramOne: "World")

        let callToZab = try assertWasCalled(
            zab(paramOne:),
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
                let callToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .exactlyOnce()
                    .matchingCall

                XCTAssertNil(callToFoo)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to foo() were recorded
                """
            }
        )
    }

    func testExactlyOnce_WithSingleCall() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        let callToRab = assertWasCalled(
            rab(paramOne:paramTwo:paramThree:),
            withSignature: "rab(paramOne:paramTwo:paramThree:)",
            expectedInput: true, 1, "Hello"
        ).exactlyOnce()
            .matchingCall

        XCTAssertNotNil(callToRab)
    }

    func testExactlyOnce_WithMultipleCalls() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callToRab = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")
                    .exactlyOnce()
                    .matchingCall

                XCTAssertNotNil(callToRab)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected rab(paramOne:paramTwo:paramThree:) to be called exactly once as specified, but 2 calls were recorded
                """
            }
        )
    }

    // MARK: - occurringTimes(_:)

    func testOccurringTimes_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .occurring(times: 1)
                    .matchingCalls

                XCTAssertTrue(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to foo() were recorded
                """
            }
        )
    }

    func testOccurringTimes_WithMultipleCalls() {
        foo()
        foo()
        foo()

        let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
            .occurring(times: 3)
            .matchingCalls

        XCTAssertEqual(callsToFoo.count, 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .occurring(times: 1)
                    .matchingCalls

                XCTAssertFalse(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called as specified 1 times, but 3 calls were recorded
                """
            }
        )
    }

    func testOccurringTimes_WithGenericParameter_WithMultipleCalls() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self).occurring(times: 1)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: String.self).occurring(times: 2)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Int.self).occurring(times: 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self)
                    .occurring(times: 4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected zab(paramOne:) to be called as specified 4 times, but 1 calls were recorded
                """
            }
        )
    }

    // MARK: - occurringWithin(_:)

    func testOccurringTimesWithin_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .occurringWithin(times: 0 ... 5)
                    .matchingCalls

                XCTAssertTrue(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to foo() were recorded
                """
            }
        )
    }

    func testOccurringTimesWithin_WithMultipleCalls() {
        foo()
        foo()
        foo()

        assertWasCalled(foo, withSignature: "foo()")
            .occurringWithin(times: 2 ... 3)

        assertWasCalled(foo, withSignature: "foo()")
            .occurringWithin(times: 3...)

        assertWasCalled(foo, withSignature: "foo()")
            .occurringWithin(times: ...3)

        assertWasCalled(foo, withSignature: "foo()")
            .occurringWithin(times: ..<4)

        let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
            .occurringWithin(times: 2 ..< 4)
            .matchingCalls

        XCTAssertEqual(callsToFoo.count, 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .occurringWithin(times: 0 ... 2)
                    .matchingCalls

                XCTAssertFalse(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called as specified within 0...2 times, but 3 calls were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .occurringWithin(times: ...2)
                    .matchingCalls

                XCTAssertFalse(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called as specified up to 2 times, but 3 calls were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .occurringWithin(times: ..<3)
                    .matchingCalls

                XCTAssertFalse(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called as specified fewer than 3 times, but 3 calls were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .occurringWithin(times: 4...)
                    .matchingCalls

                XCTAssertFalse(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called as specified at least 4 times, but 3 calls were recorded
                """
            }
        )
    }

}

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

                XCTAssertNil(callToRab)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected rab(paramOne:paramTwo:paramThree:) to be called exactly once as specified, but 2 calls were recorded
                """
            }
        )
    }

    // MARK: - withCount(_:)

    func testWithCount_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .withCount(1)
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

    func testWithCount_WithMultipleCalls() {
        foo()
        foo()
        foo()

        let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
            .withCount(3)
            .matchingCalls

        XCTAssertEqual(callsToFoo.count, 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .withCount(1)
                    .matchingCalls

                XCTAssertTrue(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called as specified 1 times, but 3 calls were recorded
                """
            }
        )
    }

    func testWithCount_WithGenericParameter_WithMultipleCalls() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self).withCount(1)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: String.self).withCount(2)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Int.self).withCount(3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self)
                    .withCount(4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected zab(paramOne:) to be called as specified 4 times, but 1 calls were recorded
                """
            }
        )
    }

    // MARK: - withinRange(_:)

    func testWithinRange_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .withinRange(0 ... 5)
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

    func testWithinRange_WithMultipleCalls() {
        foo()
        foo()
        foo()

        assertWasCalled(foo, withSignature: "foo()")
            .withinRange(2 ... 3)

        assertWasCalled(foo, withSignature: "foo()")
            .withinRange(3...)

        assertWasCalled(foo, withSignature: "foo()")
            .withinRange(...3)

        assertWasCalled(foo, withSignature: "foo()")
            .withinRange(..<4)

        let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
            .withinRange(2 ..< 4)
            .matchingCalls

        XCTAssertEqual(callsToFoo.count, 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callsToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .withinRange(0 ... 2)
                    .matchingCalls

                XCTAssertTrue(callsToFoo.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called as specified within 0...2 times, but 3 calls were recorded
                """
            }
        )
    }

    // MARK: - where(_:)

    func testWherePredicate_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToBar = assertWasCalled(bar(paramOne:), withSignature: "bar(paramOne:)").where { call in
                    call.input == false
                }.matchingCalls

                XCTAssertTrue(callsToBar.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to bar(paramOne:) were recorded
                """
            }
        )
    }

    func testWherePredicate_WithSingleCall() {
        rab(paramOne: false, paramTwo: nil, paramThree: "Hello World")

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)")
            .exactlyOnce()
            .where { call in
                call.input.2?.prefix(5) == "Hello"
            }
    }

    func testWherePredicate_WithMultipleCalls() {
        rab(paramOne: false, paramTwo: nil, paramThree: nil)
        rab(paramOne: true, paramTwo: 1, paramThree: nil)

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)").where { call in
            guard let paramTwo = call.input.1 else { return false }
            return paramTwo < 5
        }

        let callsToRab = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)").where { call in
            call.input.1 == nil && call.input.2 == nil
        }.matchingCalls

        XCTAssertEqual(callsToRab.count, 1)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToRab = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)").where { call in
                    guard let paramTwo = call.input.1 else { return false }
                    return paramTwo > 5
                }.matchingCalls

                XCTAssertTrue(callsToRab.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): rab(paramOne:paramTwo:paramThree:) was not called as specified where the given predicate returned true
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)").where { call in
                    guard let paramThree = call.input.2 else { return false }
                    return paramThree == "Hello World"
                }
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): rab(paramOne:paramTwo:paramThree:) was not called as specified where the given predicate returned true
                """
            }
        )
    }

    // MARK: - happeningFirst()

    func testHappeningFirst_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callToFoo = assertWasCalled(foo, withSignature: "foo()")
                    .happeningFirst()
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

    func testHappeningFirst_WithMultipleCalls() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 2, paramThree: "World")
        oof(paramOne: false, paramTwo: 3)

        let callToRab = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")
            .happeningFirst()
            .matchingCall

        XCTAssertNotNil(callToRab)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callToRab = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "World")
                    .happeningFirst()
                    .matchingCall

                XCTAssertNil(callToRab)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): First call was to rab(paramOne:paramTwo:paramThree:), but not as specified:

                ******* Function Call 1 *******
                signature: rab(paramOne:paramTwo:paramThree:)
                input: (true, Optional(1), Optional("Hello"))
                outputType: ()
                time: 2018-06-15 0:00:00.000
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                assertWasCalled(oof(paramOne:paramTwo:), withSignature: "oof(paramOne:paramTwo:)", expectedInput: false, 3)
                    .happeningFirst()
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected oof(paramOne:paramTwo:) to be called first, but rab(paramOne:paramTwo:paramThree:) was called first
                """
            }
        )
    }

    // MARK: - happeningLast()

    func testHappeningLast_WithoutAnyCalls() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callToFoo = assertWasCalled(foo, withSignature: "foo()", taking: Void.self)
                    .happeningLast()
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

    func testHappeningLast_WithMultipleCalls() throws {
        oof(paramOne: false, paramTwo: 1)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 3, paramThree: "World")

        let callToRab = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "World")
            .happeningLast()

        XCTAssertNotNil(callToRab)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                let callToRab = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
                    .happeningLast()
                    .matchingCall

                XCTAssertNil(callToRab)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Last call was to rab(paramOne:paramTwo:paramThree:), but not as specified:

                ******* Function Call 3 *******
                signature: rab(paramOne:paramTwo:paramThree:)
                input: (true, Optional(3), Optional("World"))
                outputType: ()
                time: 2018-06-15 0:00:02.000
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                assertWasCalled(oof(paramOne:paramTwo:), withSignature: "oof(paramOne:paramTwo:)")
                    .happeningLast()
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected oof(paramOne:paramTwo:) to be called last, but rab(paramOne:paramTwo:paramThree:) was called last
                """
            }
        )
    }

//     MARK: - happening(after:)

    func testHappeningAfter() throws {
        baz(paramOne: false)
        zab(paramOne: true)
        baz(paramOne: true)
        zab(paramOne: "Hello")

        let firstCallToBaz = try XCTUnwrap(blackBox.callsMatching(signature: "baz(paramOne:)").first)
        let lastCallToBaz = try XCTUnwrap(blackBox.callsMatching(signature: "baz(paramOne:)").last)

        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)
            .happening(after: firstCallToBaz)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
            .happening(after: firstCallToBaz)
        let callsToZab = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
            .happening(after: lastCallToBaz)
            .matchingCalls

        XCTAssertEqual(callsToZab.count, 1)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callsToZab = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: false)
                    .happening(after: firstCallToBaz)
                    .matchingCalls

                XCTAssertTrue(callsToZab.isEmpty)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): zab(paramOne:) was not called with expected input (-), but was called with other input (+):

                -false
                +true
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)
                    .happening(after: lastCallToBaz)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to zab(paramOne:) as specified were recorded after given call to baz(paramOne:)
                """
            }
        )
    }

    func testHappeningAfter_ChainedOnHappeningLast() throws {
        foo()
        rab(paramOne: false, paramTwo: nil, paramThree: "Hello World")

        let callToFoo = try XCTUnwrap(blackBox.callsMatching(signature: "foo()").first)

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)")
            .happeningLast()
            .happening(after: callToFoo)
    }

    // MARK: - happening(.immediatelyAfter(previousCall:))

    func testHappeningImmediatelyAfter() throws {
        oof(paramOne: false, paramTwo: 1)
        oof(paramOne: false, paramTwo: 3)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")

        let firstCallToOof = try XCTUnwrap(blackBox.callsMatching(signature: "oof(paramOne:paramTwo:)").first)
        let lastCallToOof = try XCTUnwrap(blackBox.callsMatching(signature: "oof(paramOne:paramTwo:)").last)
        let callToRab = try XCTUnwrap(blackBox.callsMatching(signature: "rab(paramOne:paramTwo:paramThree:)").first)

        let matchingCall = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
            .happening(immediatelyAfter: lastCallToOof)
            .matchingCall

        XCTAssertNotNil(matchingCall)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                let callToRab = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: false, 2, "Hello")
                    .happening(immediatelyAfter: lastCallToOof)
                    .matchingCall

                XCTAssertNil(callToRab)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): rab(paramOne:paramTwo:paramThree:) was not called with expected input (-), but was called with other input (+):

                -(false, Optional(2), Optional("Hello"))
                +(true, Optional(2), Optional("Hello"))
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                assertWasCalled(oof(paramOne:paramTwo:), withSignature: "oof(paramOne:paramTwo:)", expectedInput: false, 1)
                    .happening(immediatelyAfter: firstCallToOof)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): oof(paramOne:paramTwo:) was called immediately after given call to oof(paramOne:paramTwo:), but not as specified:

                ******* Function Call 2 *******
                signature: oof(paramOne:paramTwo:)
                input: (false, 3)
                outputType: ()
                time: 2018-06-15 0:00:01.000
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                assertWasCalled(oof(paramOne:paramTwo:), withSignature: "oof(paramOne:paramTwo:)")
                    .happening(immediatelyAfter: lastCallToOof)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): rab(paramOne:paramTwo:paramThree:) was called immediately after given call to oof(paramOne:paramTwo:)
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 2
                assertWasCalled(oof(paramOne:paramTwo:), withSignature: "oof(paramOne:paramTwo:)")
                    .happening(immediatelyAfter: callToRab)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls were recorded after given call to rab(paramOne:paramTwo:paramThree:)
                """
            }
        )
    }

}

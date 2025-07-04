//
// Created on 1/14/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import Testing
import XCTest

struct ConfirmationOfCallMacroTests: Sendable {

    private let spy = TestSpy()

    // MARK: - getMatchingCall()

    @Test
    func getMatchingCall_ThrowsErrorWhenNoCalls() async {
        await withKnownIssue {
            await #expect(throws: FunctionCallConfirmationError.self) {
                try await #confirmationOfCall(to: spy.foo, timeLimit: .milliseconds(1))
                    .getMatchingCall()
            }
        }
    }

    @Test
    func getMatchingCall_GetsMatchingCall() async throws {
        Task {
            spy.zab(paramOne: "Hello")
        }

        let callToZab = try await #confirmationOfCall(to: spy.zab, returning: String.self)
            .exactlyOnce()
            .getMatchingCall()

        #expect(callToZab.input == "Hello")
    }

    // MARK: - getFirstMatchingCall()

    @Test
    func getFirstMatchingCall_ThrowsErrorWhenNoCalls() async {
        await withKnownIssue {
            await #expect(throws: FunctionCallConfirmationError.self) {
                try await #confirmationOfCall(to: spy.foo, timeLimit: .milliseconds(1))
                    .occurring(times: 2)
                    .getFirstMatchingCall()
            }
        }
    }

    @Test
    func getFirstMatchingCall_GetsFirstMatchingCall() async throws {
        Task {
            spy.zab(paramOne: "Hello")
            spy.zab(paramOne: "World")
        }

        let callToZab = try await #confirmationOfCall(to: spy.zab, returning: String.self)
            .occurring(times: 2)
            .getFirstMatchingCall()

        #expect(callToZab.input == "Hello")
    }

    // MARK: - getLastMatchingCall()

    @Test
    func getLastMatchingCall_ThrowsErrorWhenNoCalls() async {
        await withKnownIssue {
            await #expect(throws: FunctionCallConfirmationError.self) {
                try await #confirmationOfCall(to: spy.foo, timeLimit: .milliseconds(1))
                    .occurring(times: 2)
                    .getLastMatchingCall()
            }
        }
    }

    @Test
    func getLastMatchingCall_GetsLastMatchingCall() async throws {
        Task {
            spy.zab(paramOne: "Hello")
            spy.zab(paramOne: "World")
        }

        let callToZab = try await #confirmationOfCall(to: spy.zab, returning: String.self)
            .occurring(times: 2)
            .getLastMatchingCall()

        #expect(callToZab.input == "World")
    }

    // MARK: - confirmationOfCall

    @Test
    func confirmationOfCall_WithoutAnyCalls_Fails() async {
        await withKnownIssue {
            await #confirmationOfCall(to: spy.foo, timeLimit: .milliseconds(1))
        } matching: { issue in
            issue.sourceLocation?.line == #line - 2 &&
                issue.sourceLocation?.fileID == #fileID &&
                issue.description == """
                Issue recorded: No calls to "foo" with input type () and output type () were recorded
                """
        }
    }

    @Test
    func confirmationOfCall_WithSingleCall_Succeeds() async {
        spy.foo()

        let call = await #confirmationOfCall(to: spy.foo).matchingCall

        #expect(call != nil)
    }

    @Test
    func confirmationOfCall_WithMultipleCalls_Succeeds() async {
        spy.foo()
        spy.foo()
        spy.foo()

        let call = await #confirmationOfCall(to: spy.foo).matchingCall

        #expect(call != nil)
    }

    // MARK: - exactlyOnce()

    @Test
    func exactlyOnce_WithSingleCall_Succeeds() async {
        Task {
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        }

        let callToRab = await #confirmationOfCall(to: spy.rab, with: true, 1, "Hello")
            .exactlyOnce()
            .matchingCall

        #expect(callToRab != nil)
    }

    @Test
    func exactlyOnce_WithMultipleCalls_Fails() async {
        await withExpectedFailureWaiting {
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

            await withKnownIssue {
                await #confirmationOfCall(
                    to: spy.rab,
                    with: true, 1, "Hello",
                    timeLimit: .milliseconds(1)
                )
                .exactlyOnce()
            } matching: { issue in
                issue.sourceLocation?.line == #line - 2 &&
                    issue.sourceLocation?.fileID == #fileID &&
                    issue.description == """
                    Issue recorded: Expected \"rab\" to be called exactly once as specified, but an additional call was recorded
                    """
            }
        }
    }

    // MARK: - occurring(times:)

    @Test
    func occurringTimes_WithLessThanExpectedAmount_Fails() async {
        Task {
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        }

        await withKnownIssue {
            await #confirmationOfCall(
                to: spy.rab,
                with: true, 1, "Hello",
                timeLimit: .milliseconds(1)
            )
            .occurring(times: 2)
        } matching: { issue in
            issue.sourceLocation?.line == #line - 2 &&
                issue.sourceLocation?.fileID == #fileID &&
                issue.description == """
                Issue recorded: Expected "rab" to be called as specified 2 times, but only 1 calls were recorded before timing out
                """
        }
    }

    @Test
    func occurringTimes_WithExpectedAmount_Succeeds() async {
        Task {
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        }

        let callsToRab = await #confirmationOfCall(
            to: spy.rab,
            with: true, 1, "Hello",
            timeLimit: .milliseconds(1)
        )
        .occurring(times: 2)
        .matchingCalls

        #expect(callsToRab.count == 2)
    }

    @Test
    func occurringTimes_WithMoreThanExpectedAmount_Fails() async {
        await withExpectedFailureWaiting {
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

            await withKnownIssue {
                await #confirmationOfCall(
                    to: spy.rab,
                    with: true, 1, "Hello"
                )
                .occurring(times: 2)
            } matching: { issue in
                issue.sourceLocation?.line == #line - 2 &&
                    issue.sourceLocation?.fileID == #fileID &&
                    issue.description == """
                    Issue recorded: Expected "rab" to be called as specified 2 times, but an additional call was recorded
                    """
            }
        }
    }

    // MARK: - occurringWithin(times:)

    @Test
    func occurringWithinTimes_WithLessThanExpectedAmount_Fails() async {
        Task {
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        }

        await withKnownIssue {
            await #confirmationOfCall(
                to: spy.rab,
                with: true, 1, "Hello",
                timeLimit: .milliseconds(1)
            )
            .occurringWithin(times: 2 ... 4)
        } matching: { issue in
            issue.sourceLocation?.line == #line - 2 &&
                issue.sourceLocation?.fileID == #fileID &&
                issue.description == """
                Issue recorded: Expected "rab" to be called as specified at least 2 times, but only 1 calls were recorded before timing out
                """
        }

        await withKnownIssue {
            await #confirmationOfCall(
                to: spy.rab,
                with: true, 1, "Hello",
                timeLimit: .milliseconds(1)
            )
            .occurringWithin(times: 2 ..< 5)
        } matching: { issue in
            issue.sourceLocation?.line == #line - 2 &&
                issue.sourceLocation?.fileID == #fileID &&
                issue.description == """
                Issue recorded: Expected "rab" to be called as specified at least 2 times, but only 1 calls were recorded before timing out
                """
        }

        await withKnownIssue {
            await #confirmationOfCall(
                to: spy.rab,
                with: true, 1, "Hello",
                timeLimit: .milliseconds(1)
            )
            .occurringWithin(times: 2...)
        } matching: { issue in
            issue.sourceLocation?.line == #line - 2 &&
                issue.sourceLocation?.fileID == #fileID &&
                issue.description == """
                Issue recorded: Expected "rab" to be called as specified at least 2 times, but only 1 calls were recorded before timing out
                """
        }
    }

    @Test
    func occurringWithinTimes_WithExpectedAmount_Succeeds() async {
        Task {
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        }

        let callsToRab = await #confirmationOfCall(
            to: spy.rab,
            with: true, 1, "Hello"
        )
        .occurringWithin(times: 2 ... 4)
        .matchingCalls

        #expect(callsToRab.count == 2)
    }

    @Test
    func occurringWithinTimes_WithMoreThanExpectedAmount_Fails() async {
        await withExpectedFailureWaiting {
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
            spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

            await withKnownIssue {
                await #confirmationOfCall(
                    to: spy.rab,
                    with: true, 1, "Hello",
                    timeLimit: .milliseconds(1)
                )
                .occurringWithin(times: 2 ... 4)
            } matching: { issue in
                issue.sourceLocation?.line == #line - 2 &&
                    issue.sourceLocation?.fileID == #fileID &&
                    issue.description == """
                    Issue recorded: Expected "rab" to be called as specified within 2...4 times, but an additional call was recorded
                    """
            }

            await withKnownIssue {
                await #confirmationOfCall(
                    to: spy.rab,
                    with: true, 1, "Hello",
                    timeLimit: .milliseconds(1)
                )
                .occurringWithin(times: 2 ..< 5)
            } matching: { issue in
                issue.sourceLocation?.line == #line - 2 &&
                    issue.sourceLocation?.fileID == #fileID &&
                    issue.description == """
                    Issue recorded: Expected "rab" to be called as specified within 2..<5 times, but an additional call was recorded
                    """
            }
        }
    }

}

//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

enum AssertWasCalledResultError: Error {
    case noCalls
}

public struct AssertWasCalledResult<Input, Output> {

    public let matchingCalls: [ConcreteFunctionCall<Input, Output>]

    /// Gets the first matching call if it exists, or throws an `AssertWasCalledResultError` if no calls are present in this result.
    public var firstMatchingCall: ConcreteFunctionCall<Input, Output> {
        get throws {
            guard let firstMatchingCall = matchingCalls.first else {
                throw AssertWasCalledResultError.noCalls
            }
            return firstMatchingCall
        }
    }

    private let blackBox: BlackBox

    init(matchingCalls: [ConcreteFunctionCall<Input, Output>], blackBox: BlackBox) {
        self.matchingCalls = matchingCalls
        self.blackBox = blackBox
    }

}

// MARK: - Assertions

extension AssertWasCalledResult {

    /// Makes a further assertion that the function was called exactly once as specified by previous assertions.
    ///
    /// - Parameters:
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching call if it was called exactly once, or an empty array if the function was not called or was called multiple times as specified.
    @discardableResult
    public func exactlyOnce(file: StaticString = #file, line: UInt = #line) -> Self {
        guard matchingCalls.count == 1 else {
            if let signature = matchingCalls.first?.signature {
                let message = "Expected \(signature) to be called exactly once as specified, but \(matchingCalls.count) calls were recorded"
                blackBox.reportFailure(message: message, file: file, line: line)
            }
            return AssertWasCalledResult(matchingCalls: [], blackBox: blackBox)
        }

        return self
    }

    /// Makes a further assertion that the function was called a specific number of times as specified by previous assertions.
    ///
    /// - Parameters:
    ///   - expectedCallCount: The expected number of times the function should have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching calls if they were called the expected number of times, or an empty array if the function was not called or was called a different number of times as specified.
    @discardableResult
    public func withCount(_ expectedCallCount: Int, file: StaticString = #file, line: UInt = #line) -> Self {
        precondition(expectedCallCount > 0, "Use assertWasNotCalled to assert a call count of 0")

        guard matchingCalls.count == expectedCallCount else {
            if let signature = matchingCalls.first?.signature {
                let message = "Expected \(signature) to be called as specified \(expectedCallCount) times, but \(matchingCalls.count) calls were recorded"
                blackBox.reportFailure(message: message, file: file, line: line)
            }
            return AssertWasCalledResult(matchingCalls: [], blackBox: blackBox)
        }

        return self
    }

    /// Makes a further assertion that the function was called a number of times within a specified range as determined by previous assertions.
    ///
    /// - Parameters:
    ///   - expectedCallCountRange: The expected range within which the function should have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching calls if they were called within the expected range of times, or an empty array if the function was not called or was called a number of times outside the specified range.
    @discardableResult
    public func withinRange<R: RangeExpression<Int>>(_ expectedCallCountRange: R, file: StaticString = #file, line: UInt = #line) -> Self {
        guard expectedCallCountRange.contains(matchingCalls.count) else {
            if let signature = matchingCalls.first?.signature {
                let message = "Expected \(signature) to be called as specified within \(expectedCallCountRange) times, but \(matchingCalls.count) calls were recorded"
                blackBox.reportFailure(message: message, file: file, line: line)
            }
            return AssertWasCalledResult(matchingCalls: [], blackBox: blackBox)
        }

        return self
    }

    /// Makes a further assertion that the function was called in a manner that satisfies the provided `predicate`.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes a `ConcreteFunctionCall<Input, Output>` and returns a Boolean value indicating whether the function call satisfies the conditions defined by the closure.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching calls if they satisfy the `predicate`, or an empty array if no calls satisfy the `predicate`.
    @discardableResult
    public func `where`(_ predicate: (ConcreteFunctionCall<Input, Output>) -> Bool, file: StaticString = #file, line: UInt = #line) -> Self {
        let filteredCalls = matchingCalls.filter(predicate)

        if filteredCalls.isEmpty, let signature = matchingCalls.first?.signature {
            let message = "\(signature) was not called as specified where the given predicate returned true"
            blackBox.reportFailure(message: message, file: file, line: line)
        }

        return AssertWasCalledResult(matchingCalls: filteredCalls, blackBox: blackBox)
    }

    /// Makes a further assertion that the function was called as specified in the given `position`.
    ///
    /// - Parameters:
    ///   - position: A `FunctionCallPosition` value that specifies the expected position of the function call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching call(s) if it happened at the specified `position`, or an empty array if no calls happened at the specified `position`.
    @discardableResult
    public func happening(_ position: FunctionCallPosition, file: StaticString = #file, line: UInt = #line) -> Self {
        switch position {
        case .first:
            assertWasCalledFirst(file: file, line: line)
        case .last:
            assertWasCalledLast(file: file, line: line)
        case .after(let previousCall):
            assertWasCalledAfter(previousCall, file: file, line: line)
        case .immediatelyAfter(let previousCall):
            assertWasCalledImmediatelyAfter(previousCall, file: file, line: line)
        }
    }

    // MARK: - Private Assertion Helpers

    private func assertWasCalledFirst(file: StaticString, line: UInt) -> Self {
        guard let firstMatchingCall = matchingCalls.first,
              let firstCallOverall = blackBox.firstCall
        else { return self } // Failure already reported

        guard firstMatchingCall.id == firstCallOverall.id else {
            let message: String

            if firstCallOverall.signature != firstMatchingCall.signature {
                message = "Expected \(firstMatchingCall.signature) to be called first, but \(firstCallOverall.signature) was called first"
            } else {
                message = "First call was to \(firstMatchingCall.signature), but not as specified:\n\n\(firstCallOverall)"
            }

            blackBox.reportFailure(message: message, file: file, line: line)
            return AssertWasCalledResult(matchingCalls: [], blackBox: blackBox)
        }

        return AssertWasCalledResult(matchingCalls: [firstMatchingCall], blackBox: blackBox)
    }

    private func assertWasCalledLast(file: StaticString, line: UInt) -> Self {
        guard let lastMatchingCall = matchingCalls.last,
              let lastCallOverall = blackBox.lastCall
        else { return self } // Failure already reported

        guard lastMatchingCall.id == lastCallOverall.id else {
            let message: String

            if lastCallOverall.signature != lastMatchingCall.signature {
                message = "Expected \(lastMatchingCall.signature) to be called last, but \(lastCallOverall.signature) was called last"
            } else {
                message = "Last call was to \(lastMatchingCall.signature), but not as specified:\n\n\(lastCallOverall)"
            }

            blackBox.reportFailure(message: message, file: file, line: line)
            return AssertWasCalledResult(matchingCalls: [], blackBox: blackBox)
        }

        return AssertWasCalledResult(matchingCalls: [lastMatchingCall], blackBox: blackBox)
    }

    private func assertWasCalledAfter(_ previousCall: any FunctionCall, file: StaticString, line: UInt) -> Self {
        let callsAfter = matchingCalls.filter { $0.time > previousCall.time }

        guard !callsAfter.isEmpty else {
            if let signature = matchingCalls.first?.signature {
                let message = "No calls to \(signature) as specified were recorded after given call to \(previousCall.signature)"
                blackBox.reportFailure(message: message, file: file, line: line)
            }
            return AssertWasCalledResult(matchingCalls: [], blackBox: blackBox)
        }

        return AssertWasCalledResult(matchingCalls: callsAfter, blackBox: blackBox)
    }

    private func assertWasCalledImmediatelyAfter(_ previousCall: any FunctionCall, file: StaticString, line: UInt) -> Self {
        guard let callAfterPreviousCall = blackBox.callAfter(previousCall) else {
            let message = "No calls were recorded after given call to \(previousCall.signature)"
            blackBox.reportFailure(message: message, file: file, line: line)
            return AssertWasCalledResult(matchingCalls: [], blackBox: blackBox)
        }

        guard let matchingCall = matchingCalls.first(where: { $0.id == callAfterPreviousCall.id }) else {
            if let signature = matchingCalls.first?.signature {
                let message: String

                if callAfterPreviousCall.signature == signature {
                    message = "\(signature) was called immediately after given call to \(previousCall.signature), but not as specified:\n\n\(callAfterPreviousCall)"
                } else {
                    message = "\(callAfterPreviousCall.signature) was called immediately after given call to \(previousCall.signature)"
                }

                blackBox.reportFailure(message: message, file: file, line: line)
            }

            return AssertWasCalledResult(matchingCalls: [], blackBox: blackBox)
        }

        return AssertWasCalledResult(matchingCalls: [matchingCall], blackBox: blackBox)
    }

}

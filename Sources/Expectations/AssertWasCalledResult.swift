//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRSCore

enum AssertWasCalledResultError: Error {
    /// No calls were made that match the assertion.
    case noCalls
}

/// `AssertWasCalledResult` is a struct that encapsulates the result of an `#assertWasCalled` assertion.
/// It contains any calls that match the assertion and provides methods for asserting the number of times the given call was recorded.
public struct AssertWasCalledResult<AmountMatching: FunctionCallAmountMatching, Input, Output> {

    private let _matchingCalls: [ConcreteFunctionCall<Input, Output>]
    private let blackBox: BlackBox

    init(matchingCalls: [ConcreteFunctionCall<Input, Output>], blackBox: BlackBox) {
        _matchingCalls = matchingCalls
        self.blackBox = blackBox
    }

}

// MARK: - Matching Calls

extension AssertWasCalledResult where AmountMatching == MatchingSingle {

    /// The matching call or `nil` if no calls were made that match the assertion.
    public var matchingCall: ConcreteFunctionCall<Input, Output>? {
        _matchingCalls.first
    }

    /// Gets the matching call if it exists, or throws an `AssertWasCalledResultError` if no calls were made that match the assertion.
    public func getMatchingCall() throws -> ConcreteFunctionCall<Input, Output> {
        guard let firstMatchingCall = _matchingCalls.first else {
            throw AssertWasCalledResultError.noCalls
        }
        return firstMatchingCall
    }

}

extension AssertWasCalledResult where AmountMatching: MatchingMultiple {

    /// The matching calls or an empty array  if no calls were made that satisfy the assertion.
    public var matchingCalls: [ConcreteFunctionCall<Input, Output>] {
        _matchingCalls
    }

    /// Gets the first matching call if it exists, or throws an `AssertWasCalledResultError` if no calls were made that match the assertion.
    public func getFirstMatchingCall() throws -> ConcreteFunctionCall<Input, Output> {
        guard let firstMatchingCall = matchingCalls.first else {
            throw AssertWasCalledResultError.noCalls
        }
        return firstMatchingCall
    }

    /// Gets the last matching call if it exists, or throws an `AssertWasCalledResultError` if no calls were made that match the assertion.
    public func getLastMatchingCall() throws -> ConcreteFunctionCall<Input, Output> {
        guard let lastMatchingCall = matchingCalls.last else {
            throw AssertWasCalledResultError.noCalls
        }
        return lastMatchingCall
    }

}

// MARK: - Assertions

extension AssertWasCalledResult where AmountMatching == MatchingAnyAmount {

    /// Makes a further assertion that the specified call occurred exactly once.
    ///
    /// - Parameters:
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: A copy of this result as an `AssertWasCalledResult<MatchingSingle, Input, Output>`.
    @discardableResult
    public func exactlyOnce(file: StaticString = #file, line: UInt = #line) -> AssertWasCalledResult<MatchingSingle, Input, Output> {
        if matchingCalls.count != 1,
           let signature = _matchingCalls.first?.signature {
            let message = "Expected \(signature) to be called exactly once as specified, but \(matchingCalls.count) calls were recorded"
            blackBox.reportFailure(message: message, file: file, line: line)
        }

        return .init(matchingCalls: _matchingCalls, blackBox: blackBox)
    }

    /// Makes a further assertion that the specified call occurred a specific number of times.
    ///
    /// - Parameters:
    ///   - expectedCallCount: The expected number of times the function should have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: A copy of this result as an `AssertWasCalledResult<MatchingSomeAmount, Input, Output>`.
    @discardableResult
    public func occurring(times expectedCallCount: Int, file: StaticString = #file, line: UInt = #line) -> AssertWasCalledResult<MatchingSomeAmount, Input, Output> {
        precondition(expectedCallCount > 0, "Use assertWasNotCalled to assert a call count of 0")

        if matchingCalls.count != expectedCallCount,
           let signature = _matchingCalls.first?.signature {
            let message = "Expected \(signature) to be called as specified \(expectedCallCount) times, but \(matchingCalls.count) calls were recorded"
            blackBox.reportFailure(message: message, file: file, line: line)
        }

        return .init(matchingCalls: _matchingCalls, blackBox: blackBox)
    }

    /// Makes a further assertion that the specified call occurred a number of times within a given range.
    ///
    /// - Parameters:
    ///   - expectedCallCountRange: The expected range within which the function should have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: A copy of this result as an `AssertWasCalledResult<MatchingSomeAmount, Input, Output>`.
    @discardableResult
    public func occurringWithin<R: RangeExpression<Int>>(times expectedCallCountRange: R, file: StaticString = #file, line: UInt = #line) -> AssertWasCalledResult<MatchingSomeAmount, Input, Output> {
        if !expectedCallCountRange.contains(matchingCalls.count),
           let signature = _matchingCalls.first?.signature {
            let message = "Expected \(signature) to be called as specified \(expectedCallCountRange.expandedDescription) times, but \(matchingCalls.count) calls were recorded"
            blackBox.reportFailure(message: message, file: file, line: line)
        }

        return .init(matchingCalls: _matchingCalls, blackBox: blackBox)
    }

}

private extension RangeExpression<Int> {

    var expandedDescription: String {
        if let partialRangeUpTo = self as? PartialRangeUpTo<Int> {
            return "fewer than \(partialRangeUpTo.upperBound)"
        } else if let partialRangeThrough = self as? PartialRangeThrough<Int> {
            return "up to \(partialRangeThrough.upperBound)"
        } else if let partialRangeFrom = self as? PartialRangeFrom<Int> {
            return "at least \(partialRangeFrom.lowerBound)"
        }

        return "within \(self)"
    }

}

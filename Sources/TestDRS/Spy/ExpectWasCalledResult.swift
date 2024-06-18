//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

enum ExpectWasCalledResultError: Error {
    /// No calls were made that match the expectation.
    case noCalls
}

/// `ExpectWasCalledResult` is a struct that encapsulates the result of an `#expectWasCalled` expectation.
/// It contains any calls that match the expectation and provides methods for expecting the number of times the given call was recorded.
public struct ExpectWasCalledResult<AmountMatching: FunctionCallAmountMatching, Input, Output> {

    private let _matchingCalls: [ConcreteFunctionCall<Input, Output>]
    private let blackBox: BlackBox
    private let reportFailure: ReportFailure

    init(matchingCalls: [ConcreteFunctionCall<Input, Output>], blackBox: BlackBox, reportFailure: @escaping ReportFailure) {
        _matchingCalls = matchingCalls
        self.blackBox = blackBox
        self.reportFailure = reportFailure
    }

}

// MARK: - Matching Calls

extension ExpectWasCalledResult where AmountMatching == MatchingSingle {

    /// The matching call or `nil` if no calls were made that match the expectation.
    public var matchingCall: ConcreteFunctionCall<Input, Output>? {
        _matchingCalls.first
    }

    /// Gets the matching call if it exists, or throws an `ExpectWasCalledResultError` if no calls were made that match the expectation.
    public func getMatchingCall() throws -> ConcreteFunctionCall<Input, Output> {
        guard let firstMatchingCall = _matchingCalls.first else {
            throw ExpectWasCalledResultError.noCalls
        }
        return firstMatchingCall
    }

}

extension ExpectWasCalledResult where AmountMatching: MatchingMultiple {

    /// The matching calls or an empty array  if no calls were made that satisfy the expectation.
    public var matchingCalls: [ConcreteFunctionCall<Input, Output>] {
        _matchingCalls
    }

    /// Gets the first matching call if it exists, or throws an `ExpectWasCalledResultError` if no calls were made that match the expectation.
    public func getFirstMatchingCall() throws -> ConcreteFunctionCall<Input, Output> {
        guard let firstMatchingCall = matchingCalls.first else {
            throw ExpectWasCalledResultError.noCalls
        }
        return firstMatchingCall
    }

    /// Gets the last matching call if it exists, or throws an `ExpectWasCalledResultError` if no calls were made that match the expectation.
    public func getLastMatchingCall() throws -> ConcreteFunctionCall<Input, Output> {
        guard let lastMatchingCall = matchingCalls.last else {
            throw ExpectWasCalledResultError.noCalls
        }
        return lastMatchingCall
    }

}

// MARK: - Expectations

extension ExpectWasCalledResult where AmountMatching == MatchingAnyAmount {

    /// Makes a further expectation that the specified call occurred exactly once.
    ///
    /// - Returns: A copy of this result as an `ExpectWasCalledResult<MatchingSingle, Input, Output>`.
    @discardableResult
    public func exactlyOnce(
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> ExpectWasCalledResult<MatchingSingle, Input, Output> {
        if matchingCalls.count != 1,
           let signature = _matchingCalls.first?.signature {
            let message = "Expected \(signature) to be called exactly once as specified, but \(matchingCalls.count) calls were recorded"

            let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
            reportFailure(message, location)
        }

        return .init(matchingCalls: _matchingCalls, blackBox: blackBox, reportFailure: reportFailure)
    }

    /// Makes a further expectation that the specified call occurred a specific number of times.
    ///
    /// - Parameters:
    ///   - expectedCallCount: The expected number of times the function should have been called.
    ///
    /// - Returns: A copy of this result as an `ExpectWasCalledResult<MatchingSomeAmount, Input, Output>`.
    @discardableResult
    public func occurring(
        times expectedCallCount: Int,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> ExpectWasCalledResult<MatchingSomeAmount, Input, Output> {
        precondition(expectedCallCount > 0, "Use expectWasNotCalled to expect a call count of 0")

        if matchingCalls.count != expectedCallCount,
           let signature = _matchingCalls.first?.signature {
            let message = "Expected \(signature) to be called as specified \(expectedCallCount) times, but \(matchingCalls.count) calls were recorded"
            let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
            reportFailure(message, location)
        }

        return .init(matchingCalls: _matchingCalls, blackBox: blackBox, reportFailure: reportFailure)
    }

    /// Makes a further expectation that the specified call occurred a number of times within a given range.
    ///
    /// - Parameters:
    ///   - expectedCallCountRange: The expected range within which the function should have been called.
    ///
    /// - Returns: A copy of this result as an `ExpectWasCalledResult<MatchingSomeAmount, Input, Output>`.
    @discardableResult
    public func occurringWithin<R: RangeExpression<Int>>(
        times expectedCallCountRange: R,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> ExpectWasCalledResult<MatchingSomeAmount, Input, Output> {
        if !expectedCallCountRange.contains(matchingCalls.count),
           let signature = _matchingCalls.first?.signature {
            let message = "Expected \(signature) to be called as specified \(expectedCallCountRange.expandedDescription) times, but \(matchingCalls.count) calls were recorded"
            let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
            reportFailure(message, location)
        }

        return .init(matchingCalls: _matchingCalls, blackBox: blackBox, reportFailure: reportFailure)
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

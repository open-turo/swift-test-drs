//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

enum AssertWasCalledResultError: Error {
    /// No calls were made that match the assertion.
    case noCalls
}

public struct AssertWasCalledResult<ResultMatching: AssertionResultMatching, Input, Output> {

    private typealias SingleResult = AssertWasCalledResult<MatchingSingle, Input, Output>
    private typealias MultipleResult = AssertWasCalledResult<MatchingMultiple, Input, Output>

    private let _matchingCalls: [ConcreteFunctionCall<Input, Output>]
    private let blackBox: BlackBox

    init(matchingCalls: [ConcreteFunctionCall<Input, Output>], blackBox: BlackBox) {
        _matchingCalls = matchingCalls
        self.blackBox = blackBox
    }

    private static func noMatch(blackbox: BlackBox) -> Self {
        Self(matchingCalls: [], blackBox: blackbox)
    }
}

// MARK: - Matching Calls

extension AssertWasCalledResult where ResultMatching == MatchingSingle {

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

    init(matchingCall: ConcreteFunctionCall<Input, Output>, blackBox: BlackBox) {
        _matchingCalls = [matchingCall]
        self.blackBox = blackBox
    }

}

extension AssertWasCalledResult where ResultMatching == MatchingMultiple {

    /// The matching calls or `nil` if no calls were made that satisfy the assertion.
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

}

// MARK: - Assertions

/// Assertions starting with any number of calls.
extension AssertWasCalledResult {

    /// Makes a further assertion that the specified call was the first to have been recorded by the `Spy`.
    ///
    /// - Parameters:
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the first call recorded by the `Spy`, or `nil` if the function was not called first as specified.
    @discardableResult
    public func happeningFirst(file: StaticString = #file, line: UInt = #line) -> AssertWasCalledResult<MatchingSingle, Input, Output> {
        happening(.first, file: file, line: line)
    }

    /// Makes a further assertion that the specified call was the last to have been recorded by the `Spy`.
    ///
    /// - Parameters:
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the last call recorded by the `Spy`, or `nil` if the function was not called last as specified.
    @discardableResult
    public func happeningLast(file: StaticString = #file, line: UInt = #line) -> AssertWasCalledResult<MatchingSingle, Input, Output> {
        happening(.last, file: file, line: line)
    }

    /// Makes a further assertion that the specified call happened immediatly after the given call.
    ///
    /// - Parameters:
    ///   - previousCall: The call that occurred before the expected call(s).
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing the call immediatly after the `previousCall`, or `nil` if the function was not called immediatly after the `previousCall` as specified.
    @discardableResult
    public func happening(immediatelyAfter previousCall: any FunctionCall, file: StaticString = #file, line: UInt = #line) -> AssertWasCalledResult<MatchingSingle, Input, Output> {
        guard let callAfterPreviousCall = blackBox.callAfter(previousCall) else {
            let message = "No calls were recorded after given call to \(previousCall.signature)"
            blackBox.reportFailure(message: message, file: file, line: line)
            return SingleResult.noMatch(blackbox: blackBox)
        }

        guard let matchingCall = _matchingCalls.first(where: { $0.id == callAfterPreviousCall.id }) else {
            if let signature = _matchingCalls.first?.signature {
                let message: String

                if callAfterPreviousCall.signature == signature {
                    message = "\(signature) was called immediately after given call to \(previousCall.signature), but not as specified:\n\n\(callAfterPreviousCall)"
                } else {
                    message = "\(callAfterPreviousCall.signature) was called immediately after given call to \(previousCall.signature)"
                }

                blackBox.reportFailure(message: message, file: file, line: line)
            }

            return SingleResult.noMatch(blackbox: blackBox)
        }

        return SingleResult(matchingCall: matchingCall, blackBox: blackBox)
    }

}

/// Assertions starting with a single call.
extension AssertWasCalledResult where ResultMatching == MatchingSingle {

    /// Makes a further assertion that the specified call ocurreed in a manner that satisfies the provided `predicate`.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes a `ConcreteFunctionCall<Input, Output>` and returns a Boolean value indicating whether the function call satisfies the conditions defined by the closure.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching call if it satisfies the `predicate`, or `nil` if it does not satisfy the `predicate`.
    @discardableResult
    public func `where`(_ predicate: (ConcreteFunctionCall<Input, Output>) -> Bool, file: StaticString = #file, line: UInt = #line) -> Self {
        _where(predicate, file: file, line: line)
    }

    /// Makes a further assertion that the specified call happened after the given call.
    ///
    /// - Parameters:
    ///   - previousCall: The call that occurred before the expected call(s).
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing the matching call, or `nil` if the function was not called as specified after the `previousCall`.
    @discardableResult
    public func happening(after previousCall: any FunctionCall, file: StaticString = #file, line: UInt = #line) -> Self {
        _happening(after: previousCall, file: file, line: line)
    }
}

/// Assertions starting with a multiple calls.
extension AssertWasCalledResult where ResultMatching == MatchingMultiple {

    /// Makes a further assertion that the speficied call ocurred at least once in a manner that satisfies the provided `predicate`.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes a `ConcreteFunctionCall<Input, Output>` and returns a Boolean value indicating whether the function call satisfies the conditions defined by the closure.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching calls that satisfy the `predicate`, or an empty array if no calls satisfy the `predicate`.
    @discardableResult
    public func `where`(_ predicate: (ConcreteFunctionCall<Input, Output>) -> Bool, file: StaticString = #file, line: UInt = #line) -> Self {
        _where(predicate, file: file, line: line)
    }

    /// Makes a further assertion that the specified call happened at least once after the given call.
    ///
    /// - Parameters:
    ///   - previousCall: The call that occurred before the expected call(s).
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing the matching calls, or an empty array if the function was not called as specified after the `previousCall`.
    @discardableResult
    public func happening(after previousCall: any FunctionCall, file: StaticString = #file, line: UInt = #line) -> Self {
        _happening(after: previousCall, file: file, line: line)
    }

    /// Makes a further assertion that the specified call ocurred exactly once.
    ///
    /// - Parameters:
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching call if it ocurred exactly once, or an empty array if the call occurred zero or multiple times.
    @discardableResult
    public func exactlyOnce(file: StaticString = #file, line: UInt = #line) -> AssertWasCalledResult<MatchingSingle, Input, Output> {
        guard matchingCalls.count == 1, let firstMatchingCall = matchingCalls.first else {
            if let signature = matchingCalls.first?.signature {
                let message = "Expected \(signature) to be called exactly once as specified, but \(matchingCalls.count) calls were recorded"
                blackBox.reportFailure(message: message, file: file, line: line)
            }
            return SingleResult.noMatch(blackbox: blackBox)
        }

        return SingleResult(matchingCall: firstMatchingCall, blackBox: blackBox)
    }

    /// Makes a further assertion that the specified call occurred a specific number of times.
    ///
    /// - Parameters:
    ///   - expectedCallCount: The expected number of times the function should have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching calls if ocurring the expected number of times, or an empty array if the call ocurred a different number of times than specified.
    @discardableResult
    public func withCount(_ expectedCallCount: Int, file: StaticString = #file, line: UInt = #line) -> Self {
        precondition(expectedCallCount > 0, "Use assertWasNotCalled to assert a call count of 0")

        guard matchingCalls.count == expectedCallCount else {
            if let signature = matchingCalls.first?.signature {
                let message = "Expected \(signature) to be called as specified \(expectedCallCount) times, but \(matchingCalls.count) calls were recorded"
                blackBox.reportFailure(message: message, file: file, line: line)
            }
            return Self.noMatch(blackbox: blackBox)
        }

        return self
    }

    /// Makes a further assertion that the specified call occurred a number of times within a given range.
    ///
    /// - Parameters:
    ///   - expectedCallCountRange: The expected range within which the function should have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    ///
    /// - Returns: An `AssertWasCalledResult` containing either the matching calls if ocurring within the expected range of times, or an empty array if the call occurred a number of times outside the specified range.
    @discardableResult
    public func withinRange<R: RangeExpression<Int>>(_ expectedCallCountRange: R, file: StaticString = #file, line: UInt = #line) -> Self {
        guard expectedCallCountRange.contains(matchingCalls.count) else {
            if let signature = matchingCalls.first?.signature {
                let message = "Expected \(signature) to be called as specified within \(expectedCallCountRange) times, but \(matchingCalls.count) calls were recorded"
                blackBox.reportFailure(message: message, file: file, line: line)
            }
            return Self.noMatch(blackbox: blackBox)
        }

        return self
    }

}

// MARK: - Private Assertion Helpers

extension AssertWasCalledResult {

    private enum FirstOrLast: String {
        case first
        case last
    }

    private func happening(_ firstOrLast: FirstOrLast, file: StaticString, line: UInt) -> AssertWasCalledResult<MatchingSingle, Input, Output> {
        guard let firstOrLastMatchingCall = firstOrLast == .first ? _matchingCalls.first : _matchingCalls.last,
              let firstOrLastCallOverall = firstOrLast == .first ? blackBox.firstCall : blackBox.lastCall
        else { return SingleResult.noMatch(blackbox: blackBox) }

        guard firstOrLastMatchingCall.id == firstOrLastCallOverall.id else {
            let message: String

            if firstOrLastCallOverall.signature != firstOrLastMatchingCall.signature {
                message = "Expected \(firstOrLastMatchingCall.signature) to be called \(firstOrLast.rawValue), but \(firstOrLastCallOverall.signature) was called \(firstOrLast.rawValue)"
            } else {
                message = "\(firstOrLast.rawValue.capitalized) call was to \(firstOrLastMatchingCall.signature), but not as specified:\n\n\(firstOrLastCallOverall)"
            }

            blackBox.reportFailure(message: message, file: file, line: line)
            return SingleResult.noMatch(blackbox: blackBox)
        }

        return SingleResult(matchingCall: firstOrLastMatchingCall, blackBox: blackBox)
    }

    /// Shared private implementation of `happening(after:file:line:)`, allows for different documentation for `SingleResultMatching` vs `MultipleResultMatching`.
    private func _happening(after previousCall: any FunctionCall, file: StaticString, line: UInt) -> Self {
        let callsAfter = _matchingCalls.filter { $0.time > previousCall.time }

        guard !callsAfter.isEmpty else {
            if let signature = _matchingCalls.first?.signature {
                let message = "No calls to \(signature) as specified were recorded after given call to \(previousCall.signature)"
                blackBox.reportFailure(message: message, file: file, line: line)
            }
            return Self.noMatch(blackbox: blackBox)
        }

        return Self(matchingCalls: callsAfter, blackBox: blackBox)
    }

    /// Shared private implementation of `where(_:file:line:)`, allows for different documentation for `SingleResultMatching` vs `MultipleResultMatching`.
    private func _where(_ predicate: (ConcreteFunctionCall<Input, Output>) -> Bool, file: StaticString, line: UInt) -> Self {
        let filteredCalls = _matchingCalls.filter(predicate)

        if filteredCalls.isEmpty, let signature = _matchingCalls.first?.signature {
            let message = "\(signature) was not called as specified where the given predicate returned true"
            blackBox.reportFailure(message: message, file: file, line: line)
        }

        return Self(matchingCalls: filteredCalls, blackBox: blackBox)
    }

}

//
// Created on 7/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

enum FunctionCallConfirmationError: Error {
    /// No matching calls were confirmed.
    case noCalls
}

/// `FunctionCallConfirmation` is a struct that encapsulates the result of a `#confirmationOfCall`.
/// It contains any calls that match the confirmation and provides methods for confirming the number of times the given call was recorded.
public struct FunctionCallConfirmation<AmountMatching: FunctionCallAmountMatching, Input, Output>: Sendable {

    private var _matchingCalls: [FunctionCall<Input, Output>] = []

    private let stream: AsyncStream<FunctionCall<Input, Output>>
    private let signature: FunctionSignature
    private let blackBox: BlackBox
    private let timeLimit: Duration

    private init(
        stream: AsyncStream<FunctionCall<Input, Output>>,
        signature: FunctionSignature,
        blackBox: BlackBox,
        timeLimit: Duration,
        matchingCalls: [FunctionCall<Input, Output>] = [],
        isolation: isolated(any Actor)? = #isolation
    ) {
        self.stream = stream
        self.signature = signature
        self.blackBox = blackBox
        self.timeLimit = timeLimit
        _matchingCalls = matchingCalls
    }

    private func copy<T>() -> FunctionCallConfirmation<T, Input, Output> {
        .init(
            stream: stream,
            signature: signature,
            blackBox: blackBox,
            timeLimit: timeLimit,
            matchingCalls: _matchingCalls
        )
    }

}

extension FunctionCallConfirmation where AmountMatching == MatchingFirst {

    static func confirmFirstCall(
        stream: AsyncStream<FunctionCall<Input, Output>>,
        signature: FunctionSignature,
        blackBox: BlackBox,
        timeLimit: Duration,
        location: SourceLocation
    ) async -> Self {
        let confirmation = FunctionCallConfirmation(
            stream: stream,
            signature: signature,
            blackBox: blackBox,
            timeLimit: timeLimit
        )
        return await confirmation.confirmationOfFirstCall(location: location)
    }

    private func confirmationOfFirstCall(location: SourceLocation) async -> Self {
        var copy: Self = copy()

        defer {
            if copy._matchingCalls.isEmpty {
                let message = "No calls to \(signature) with input type \(Input.self) and output type \(Output.self) were recorded"
                reportFailure(message, location: location)
            }
        }

        let confirmationTask = Task { [copy] in
            var confirmation = copy
            for await call in stream.prefix(1) {
                confirmation._matchingCalls.append(call)
            }
            return confirmation
        }

        let timeLimitTask = Task {
            try await Task.sleep(for: timeLimit)
            confirmationTask.cancel()
        }

        copy = await confirmationTask.value
        timeLimitTask.cancel()

        return copy
    }

}

// MARK: - Matching Calls

extension FunctionCallConfirmation where AmountMatching: MatchingSingle {

    /// The matching call or `nil` if no calls were made that match the expectation.
    public var matchingCall: FunctionCall<Input, Output>? {
        _matchingCalls.first
    }

    /// Gets the matching call if it exists, or throws an `FunctionCallConfirmationError` if no calls were made that match the expectation.
    public func getMatchingCall() throws -> FunctionCall<Input, Output> {
        guard let firstMatchingCall = _matchingCalls.first else {
            throw FunctionCallConfirmationError.noCalls
        }
        return firstMatchingCall
    }

}

extension FunctionCallConfirmation where AmountMatching: MatchingMultiple {

    /// The matching calls or an empty array  if no calls were confirmed.
    public var matchingCalls: [FunctionCall<Input, Output>] {
        _matchingCalls
    }

    /// Gets the first matching call if it exists, or throws an `FunctionCallConfirmationError` if no calls were confirmed.
    public func getFirstMatchingCall() throws -> FunctionCall<Input, Output> {
        guard let firstMatchingCall = matchingCalls.first else {
            throw FunctionCallConfirmationError.noCalls
        }
        return firstMatchingCall
    }

    /// Gets the last matching call if it exists, or throws an `FunctionCallConfirmationError` if no calls were confirmed.
    public func getLastMatchingCall() throws -> FunctionCall<Input, Output> {
        guard let lastMatchingCall = matchingCalls.last else {
            throw FunctionCallConfirmationError.noCalls
        }
        return lastMatchingCall
    }

}

// MARK: - Confirming amount

extension FunctionCallConfirmation where AmountMatching == MatchingFirst, Input: Sendable {

    /// Makes a further confirmation that the specified call occurred exactly once.
    ///
    /// - Note: Additional calls may be made after the test finishes without causing failure.
    /// This can occur because this method does not introduce a delay in order to wait for failures.
    ///
    /// - Returns: A copy of this confirmation as an `FunctionCallConfirmation<MatchingOne, Input, Output>`.
    @discardableResult
    public func exactlyOnce(
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async -> FunctionCallConfirmation<MatchingOne, Input, Output> {
        let failureTask = Task {
            for await _ in stream.prefix(1) {
                let message = "Expected \(signature) to be called exactly once as specified, but an additional call was recorded"
                let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
                reportFailure(message, location: location)
            }
        }

        if ExpectedFailure.shouldWaitForFailure {
            await failureTask.value
        }

        return copy()
    }

    /// Makes a further confirmation that the specified call occurred a specific number of times.
    ///
    /// - Note: Additional calls may be made after the test finishes without causing failure.
    /// This can occur because this method does not introduce a delay in order to wait for failures.
    ///
    /// - Parameters:
    ///   - expectedCallCount: The expected number of times the function should have been called.
    ///
    /// - Returns: A `FunctionCallConfirmation<MatchingSomeAmount, Input, Output>` that has attempted to await the `expectedCallCount` number of matching calls.
    @discardableResult
    public func occurring(
        times expectedCallCount: Int,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async -> FunctionCallConfirmation<MatchingSomeAmount, Input, Output> {
        precondition(expectedCallCount > 0, "Function call confirmations only support confirming positive call counts")

        var copy: FunctionCallConfirmation<MatchingSomeAmount, Input, Output> = copy()

        defer {
            if copy._matchingCalls.count < expectedCallCount {
                let message = "Expected \(signature) to be called as specified \(expectedCallCount) times, but only \(copy.matchingCalls.count) calls were recorded before timing out"
                let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
                reportFailure(message, location: location)
            }
        }

        let confirmationTask = Task { [copy] in
            var confirmation = copy
            // - 1 accounts for the initial call awaited in confirmationOfFirstCall
            for await call in stream.prefix(expectedCallCount - 1) {
                confirmation._matchingCalls.append(call)
            }
            return confirmation
        }

        let timeLimitTask = Task {
            try await Task.sleep(for: timeLimit)
            confirmationTask.cancel()
        }

        copy = await confirmationTask.value
        timeLimitTask.cancel()

        let failureTask = Task {
            for await _ in stream.prefix(1) {
                let message = "Expected \(signature) to be called as specified \(expectedCallCount) times, but an additional call was recorded"
                let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
                reportFailure(message, location: location)
            }
        }

        if ExpectedFailure.shouldWaitForFailure {
            await failureTask.value
        }

        return copy
    }

    /// Makes a further confirmation that the specified call occurred a number of times within a given range.
    ///
    /// - Note: Additional calls beyond the upper bound of the `expectedCallCountRange` may be made after the test finishes without causing failure.
    /// This can occur because this method does not introduce a delay in order to wait for failures.
    ///
    /// - Parameters:
    ///   - expectedCallCountRange: The expected range within which the function should have been called.
    ///
    /// - Returns: A `FunctionCallConfirmation<MatchingSomeAmount, Input, Output>` that has attempted to await the minimum number of matching calls within the `expectedCallCountRange`.
    @discardableResult
    public func occurringWithin<R: RangeExpression<Int>>(
        times expectedCallCountRange: R,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async -> FunctionCallConfirmation<MatchingSomeAmount, Input, Output> where R: LowerBoundProviding, R: Sendable {
        let lowerBound = expectedCallCountRange.lowerBound
        var copy: FunctionCallConfirmation<MatchingSomeAmount, Input, Output> = copy()

        defer {
            if copy._matchingCalls.count < lowerBound {
                let message = "Expected \(signature) to be called as specified at least \(lowerBound) times, but only \(copy.matchingCalls.count) calls were recorded before timing out"
                let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
                reportFailure(message, location: location)
            }
        }

        let confirmationTask = Task { [copy] in
            var confirmation = copy
            // - 1 accounts for the initial call awaited in confirmationOfFirstCall
            for await call in stream.prefix(lowerBound - 1) {
                confirmation._matchingCalls.append(call)
            }
            return confirmation
        }

        let timeLimitTask = Task {
            try await Task.sleep(for: timeLimit)
            confirmationTask.cancel()
        }

        copy = await confirmationTask.value
        timeLimitTask.cancel()

        // A PartialRangeFrom does not have an upper bound, so we don't need to check for additional calls in that case
        guard !(expectedCallCountRange is PartialRangeFrom<Int>) else { return copy }

        let failureTask = Task {
            var additionalCount = 0
            for await _ in stream {
                additionalCount += 1
                let totalCount = lowerBound + additionalCount
                if !expectedCallCountRange.contains(totalCount) {
                    let message = "Expected \(signature) to be called as specified within \(expectedCallCountRange) times, but an additional call was recorded"
                    let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
                    reportFailure(message, location: location)
                    break
                }
            }
        }

        if ExpectedFailure.shouldWaitForFailure {
            await failureTask.value
        }

        return copy
    }

}

enum ExpectedFailure {
    /// Allows for testing expected failures by waiting for a failure to occur
    @TaskLocal static var shouldWaitForFailure = false
}

//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Extension for `Spy` that provides assertion methods for verifying call counts and call order.
public extension Spy {

    /// Asserts that the call count for a given signature matches the expected count.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   - expectedCount: The expected call count.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    func assertCallCount(
        to signature: String,
        equals expectedCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let calls = blackBox.callsMatching(signature: signature)
        if calls.count != expectedCount {
            var message = "Expected \(signature) to be called \(expectedCount) times, but \(calls.count) calls were recorded\n"
            message += calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            reportFailure(message: message, file: file, line: line)
        }
    }

    /// Asserts that the call count for a given signature and input type matches the expected count.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   - inputType: The type of input parameter(s) for the function.
    ///   - expectedCount: The expected call count.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    func assertCallCount<Input>(
        to signature: String,
        withInputType inputType: Input.Type,
        equals expectedCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let calls = blackBox.callsMatching(signature: signature, taking: inputType)
        if calls.count != expectedCount {
            var message = "Expected \(signature) to be called \(expectedCount) times, but \(calls.count) calls were recorded\n"
            message += calls
                .map { "+\(String(describing: $0.input))" }
                .joined(separator: "\n")
            reportFailure(message: message, file: file, line: line)
        }
    }

    /// Asserts that a function with the given signature was called with the expected input.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        let calls = blackBox.callsMatching(signature: signature, taking: (repeat each T).self)
        guard !calls.isEmpty else {
            if blackBox.callsMatching(signature: signature).isEmpty {
                reportFailure(message: "No calls to \(signature) were recorded", file: file, line: line)
            } else {
                reportFailure(message: "No calls to \(signature) with input type \((repeat each T).self) were recorded", file: file, line: line)
            }
            return nil
        }
        guard let call = calls.first(where: { check(repeat each expectedInput, against: $0.input) }) else {
            var message = "\(signature) was not called with expected input (-), but was called with other input (+):\n-\((repeat each expectedInput))\n"
            message += calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            reportFailure(message: message, file: file, line: line)
            return nil
        }
        return call
    }

    /// Asserts that a function with the given signature was called exactly once with the expected input.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalledExactlyOnce<each Input>(
        _ signature: String,
        with expectedInput: repeat each Input,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each Input: Equatable {
        let calls = blackBox.callsMatching(signature: signature)
        guard calls.count == 1, let onlyCall = calls.first else {
            let message = "Expected \(signature) to be called exactly once, but \(calls.count) calls were recorded\n"
            reportFailure(message: message, file: file, line: line)
            return nil
        }
        guard check(repeat each expectedInput, against: onlyCall.input) else {
            reportFailure(message: "\(signature) was called exactly once, but with different input (+) than expected (-):\n-\((repeat each expectedInput))\n+\(onlyCall.input)", file: file, line: line)
            return nil
        }
        return onlyCall
    }

    /// Asserts that the first call to a function with the given signature was made with the expected input.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalledFirst<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        guard let firstCall = firstCall(signature: signature, file: file, line: line) else { return nil }
        guard check(repeat each expectedInput, against: firstCall.input) else {
            reportFailure(message: "First call was to \(signature), but with different input (+) than expected (-):\n-\((repeat each expectedInput))\n+\(firstCall.input)", file: file, line: line)
            return nil
        }
        return firstCall
    }

    /// Asserts that the last call to a function with the given signature was made with the expected input.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - previousCall: If provided, this call must have occured immediately before the last call. Defaults to `nil`.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The last matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalledLast<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        guard let lastCall = lastCall(signature: signature, file: file, line: line) else { return nil }
        guard check(repeat each expectedInput, against: lastCall.input) else {
            reportFailure(message: "Last call was to \(signature), but with different input (+) than expected (-):\n-\((repeat each expectedInput))\n+\(lastCall.input)", file: file, line: line)
            return nil
        }
        if let previousCall {
            guard let nextCall = nextCall(after: previousCall, signature: signature, file: file, line: line) else { return nil }
            guard lastCall.signature == nextCall.signature && lastCall.time == nextCall.time else {
                reportFailure(message: "Last call was not immediately after previous call to \(previousCall.signature)", file: file, line: line)
                return nil
            }
        }
        return lastCall
    }

    /// Asserts that a function with the given signature was called with the expected input after a previous call.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - previousCall: A previous function call that must come before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        after previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        let calls = blackBox.callsMatching(signature: signature, after: previousCall, taking: (repeat each T).self)
        guard !calls.isEmpty else {
            if blackBox.callsMatching(signature: signature).isEmpty {
                reportFailure(message: "No calls to \(signature) were recorded", file: file, line: line)
            } else {
                reportFailure(message: "No calls to \(signature) with input type \((repeat each T).self) were recorded", file: file, line: line)
            }
            return nil
        }
        guard let call = calls.first(where: { check(repeat each expectedInput, against: $0.input) }) else {
            var message = "\(signature) was not called with expected input (-), but was called with other input (+) after previous call to \(previousCall.signature):\n-\((repeat each expectedInput))\n"
            message += calls
                .map { "+\($0.input)" }
                .joined(separator: "\n")
            reportFailure(message: message, file: file, line: line)
            return nil
        }
        return call
    }

    /// Asserts that a function with the given signature was called with the expected input immediately after a previous call.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - previousCall: The previous function call that must come immediately before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        guard let nextCall = nextCall(after: previousCall, signature: signature, file: file, line: line) else { return nil }
        guard check(repeat each expectedInput, against: nextCall.input) else {
            reportFailure(message: "\(signature) was called with different input (+) than expected (-) after previous call to \(previousCall.signature):\n-\((repeat each expectedInput))\n+\(nextCall.input)", file: file, line: line)
            return nil
        }
        return nextCall
    }

}

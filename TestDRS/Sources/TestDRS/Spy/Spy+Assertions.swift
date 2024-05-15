//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// MARK: - Instance methods

/// Extension for `Spy` that provides assertion methods for verifying call counts and call order.
public extension Spy {

    /// Asserts that the call count for a given signature matches the expected count.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedCount: The expected number of times for the function to have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    func assertCallCount(
        to signature: String,
        equals expectedCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        blackBox.assertCallCount(to: signature, equals: expectedCount, file: file, line: line)
    }

    /// Asserts that the call count for a given signature and input type matches the expected count.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: The type of input parameter(s) for the function.
    ///   - expectedCount: The expected number of times for the function to have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    func assertCallCount<Input>(
        to signature: String,
        withInputType inputType: Input.Type,
        equals expectedCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        blackBox.assertCallCount(to: signature, withInputType: inputType, equals: expectedCount, file: file, line: line)
    }

    /// Asserts that a function with the given signature was called with the expected input.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
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
        blackBox.assertWasCalled(signature, with: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that a function with the given signature was called exactly once with the expected input.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
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
        blackBox.assertWasCalledExactlyOnce(signature, with: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the first call to a function with the given signature was made with the expected input.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
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
        blackBox.assertWasCalledFirst(signature, with: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the last call to a function with the given signature was made with the expected input.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
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
        blackBox.assertWasCalledLast(signature, with: repeat each expectedInput, immediatelyAfter: previousCall, file: file, line: line)
    }

    /// Asserts that a function with the given signature was called with the expected input after a previous call.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
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
        blackBox.assertWasCalled(signature, with: repeat each expectedInput, after: previousCall, file: file, line: line)
    }

    /// Asserts that a function with the given signature was called with the expected input immediately after a previous call.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
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
        blackBox.assertWasCalled(signature, with: repeat each expectedInput, immediatelyAfter: previousCall, file: file, line: line)
    }

}

// TODO: The static versions of each method could be generated by a macro.

// MARK: - Static methods

/// Extension for `Spy` that provides assertion methods for verifying call counts and call order.
public extension Spy {

    /// Asserts that the call count for a given signature matches the expected count.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedCount: The expected number of times for the function to have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    static func assertCallCount(
        to signature: String,
        equals expectedCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        blackBox.assertCallCount(to: signature, equals: expectedCount, file: file, line: line)
    }

    /// Asserts that the call count for a given signature and input type matches the expected count.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: The type of input parameter(s) for the function.
    ///   - expectedCount: The expected number of times for the function to have been called.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    static func assertCallCount<Input>(
        to signature: String,
        withInputType inputType: Input.Type,
        equals expectedCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        blackBox.assertCallCount(to: signature, withInputType: inputType, equals: expectedCount, file: file, line: line)
    }

    /// Asserts that a function with the given signature was called.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to stub, which can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        blackBox.assertWasCalled(signature, with: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that a function with the given signature was called exactly once.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalledExactlyOnce<each Input>(
        _ signature: String,
        with expectedInput: repeat each Input,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each Input: Equatable {
        blackBox.assertWasCalledExactlyOnce(signature, with: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the function with the given signature was the first to be called.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalledFirst<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        blackBox.assertWasCalledFirst(signature, with: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the function with the given signature was the last to be called.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - previousCall: If provided, this call must have occured immediately before the last call. Defaults to `nil`.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The last matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalledLast<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        blackBox.assertWasCalledLast(signature, with: repeat each expectedInput, immediatelyAfter: previousCall, file: file, line: line)
    }

    /// Asserts that a function with the given signature was called with the expected input after a previous call.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - previousCall: A previous function call that must come before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        after previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        blackBox.assertWasCalled(signature, with: repeat each expectedInput, after: previousCall, file: file, line: line)
    }

    /// Asserts that a function with the given signature was called with the expected input immediately after a previous call.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - previousCall: The previous function call that must come immediately before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<each T>(
        _ signature: String,
        with expectedInput: repeat each T,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (any FunctionCall)? where repeat each T: Equatable {
        blackBox.assertWasCalled(signature, with: repeat each expectedInput, immediatelyAfter: previousCall, file: file, line: line)
    }

}

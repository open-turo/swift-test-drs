//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// swiftformat:disable spaceAroundOperators

// MARK: - Instance methods

/// Extension for `Spy` that provides assertion methods for verifying call counts and call order.
public extension Spy {

    // MARK: - assertCallCount

    /// Asserts that the call count for a given function matches the expected count.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert the call count of.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedCount: The expected number of times for the function to have been called.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    func assertCallCount<Input, Output>(
        to function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        equals expectedCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        blackBox.assertCallCount(to: function, signature: signature, equals: expectedCount, file: file, line: line)
    }

    // MARK: - assertWasCalled

    /// Asserts that the given function was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalled(function, signature: signature, expectedInput: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the given function was called, with the option of specifying a predicate that must return true to be considered a match.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - predicate: A closure that takes in a function call and returns `true` if the call should be considered a match.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        where predicate: ((ConcreteFunctionCall<Input, Output>) throws -> Bool)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalled(function, signature: signature, where: predicate, file: file, line: line)
    }

    // MARK: - assertWasCalledExactlyOnce

    /// Asserts that the given function was called exactly once, and was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called exactly once.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalledExactlyOnce<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalledExactlyOnce(function, signature: signature, expectedInput: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the given function was called exactly once.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called exactly once.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalledExactlyOnce<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalledExactlyOnce(function, signature: signature, file: file, line: line)
    }

    // MARK: - assertWasCalledFirst

    /// Asserts that the given function was the first to be called, and was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called first.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first function call or `nil` if no calls were made, the first call was to a different function, or the first call was not with the expected input.
    @discardableResult
    func assertWasCalledFirst<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalledFirst(function, signature: signature, expectedInput: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the given function was the first to be called, and was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called first.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first function call or `nil` if no calls were made, or the first call was to a different function.
    @discardableResult
    func assertWasCalledFirst<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalledFirst(function, signature: signature, file: file, line: line)
    }

    // MARK: - assertWasCalledLast

    /// Asserts that the given function was the last to be called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called last.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: If provided, this call must have occured immediately before the last call. Defaults to `nil`.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The last function call or `nil` if no calls were made, the last call was to a different function, the last call was not with the expected input, or the last call did not occur after the given previous call.
    @discardableResult
    func assertWasCalledLast<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalledLast(function, signature: signature, expectedInput: repeat each expectedInput, immediatelyAfter: previousCall, file: file, line: line)
    }

    /// Asserts that the given function was the last to be called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called last.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: If provided, this call must have occured immediately before the last call. Defaults to `nil`.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The last function call or `nil` if no calls were made, the last call was to a different function, or the last call did not occur after the given previous call.
    @discardableResult
    func assertWasCalledLast<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning: Output.Type? = nil,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalledLast(function, signature: signature, immediatelyAfter: previousCall, file: file, line: line)
    }

    // MARK: - assertWasCalled...after:

    /// Asserts that the given function was called with the expected input after a previous call.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called after the previous call.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: A previous function call that must come before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        after previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalled(function, signature: signature, expectedInput: repeat each expectedInput, after: previousCall, file: file, line: line)
    }

    /// Asserts that the given function was called with the expected input after a previous call.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called after the previous call.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: A previous function call that must come before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning: Output.Type? = nil,
        after previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalled(function, signature: signature, after: previousCall, file: file, line: line)
    }

    // MARK: - assertWasCalled...immediatelyAfter:

    /// Asserts that the given function was called with the expected input immediately after a previous call.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called after the previous call.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: A previous function call that must come immediately before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalled(function, signature: signature, expectedInput: repeat each expectedInput, immediatelyAfter: previousCall, file: file, line: line)
    }

    /// Asserts that the given function was called with the expected input immediately after a previous call.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called after the previous call.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: A previous function call that must come immediately before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning: Output.Type? = nil,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalled(function, signature: signature, immediatelyAfter: previousCall, file: file, line: line)
    }

}

// TODO: The static versions of each method could be generated by a macro.

// MARK: - Static methods

/// Extension for `Spy` that provides assertion methods for verifying call counts and call order.
public extension Spy {

    // MARK: - assertCallCount

    /// Asserts that the call count for a given function matches the expected count.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert the call count of.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedCount: The expected number of times for the function to have been called.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    static func assertCallCount<Input, Output>(
        to function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        equals expectedCount: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        blackBox.assertCallCount(to: function, signature: signature, equals: expectedCount, file: file, line: line)
    }

    // MARK: - assertWasCalled

    /// Asserts that the given function was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalled(function, signature: signature, expectedInput: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the given function was called, with the option of specifying a predicate that must return true to be considered a match.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - predicate: A closure that takes in a function call and returns `true` if the call should be considered a match.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        where predicate: ((ConcreteFunctionCall<Input, Output>) throws -> Bool)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalled(function, signature: signature, where: predicate, file: file, line: line)
    }

    // MARK: - assertWasCalledExactlyOnce

    /// Asserts that the given function was called exactly once, and was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called exactly once.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalledExactlyOnce<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalledExactlyOnce(function, signature: signature, expectedInput: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the given function was called exactly once.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called exactly once.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalledExactlyOnce<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalledExactlyOnce(function, signature: signature, file: file, line: line)
    }

    // MARK: - assertWasCalledFirst

    /// Asserts that the given function was the first to be called, and was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called first.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first function call or `nil` if no calls were made, the first call was to a different function, or the first call was not with the expected input.
    @discardableResult
    static func assertWasCalledFirst<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalledFirst(function, signature: signature, expectedInput: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the given function was the first to be called, and was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called first.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The first function call or `nil` if no calls were made, or the first call was to a different function.
    @discardableResult
    static func assertWasCalledFirst<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalledFirst(function, signature: signature, file: file, line: line)
    }

    // MARK: - assertWasCalledLast

    /// Asserts that the given function was the last to be called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called last.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: If provided, this call must have occured immediately before the last call. Defaults to `nil`.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The last function call or `nil` if no calls were made, the last call was to a different function, the last call was not with the expected input, or the last call did not occur after the given previous call.
    @discardableResult
    static func assertWasCalledLast<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalledLast(function, signature: signature, expectedInput: repeat each expectedInput, immediatelyAfter: previousCall, file: file, line: line)
    }

    /// Asserts that the given function was the last to be called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called last.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: If provided, this call must have occured immediately before the last call. Defaults to `nil`.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The last function call or `nil` if no calls were made, the last call was to a different function, or the last call did not occur after the given previous call.
    @discardableResult
    static func assertWasCalledLast<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning: Output.Type? = nil,
        immediatelyAfter previousCall: (any FunctionCall)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalledLast(function, signature: signature, immediatelyAfter: previousCall, file: file, line: line)
    }

    // MARK: - assertWasCalled...after:

    /// Asserts that the given function was called with the expected input after a previous call.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called after the previous call.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: A previous function call that must come before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        after previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalled(function, signature: signature, expectedInput: repeat each expectedInput, after: previousCall, file: file, line: line)
    }

    /// Asserts that the given function was called with the expected input after a previous call.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called after the previous call.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: A previous function call that must come before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning: Output.Type? = nil,
        after previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalled(function, signature: signature, after: previousCall, file: file, line: line)
    }

    // MARK: - assertWasCalled...immediatelyAfter:

    /// Asserts that the given function was called with the expected input immediately after a previous call.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called after the previous call.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: A previous function call that must come immediately before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<(repeat each Input), Output>? where repeat each Input: Equatable {
        blackBox.assertWasCalled(function, signature: signature, expectedInput: repeat each expectedInput, immediatelyAfter: previousCall, file: file, line: line)
    }

    /// Asserts that the given function was called with the expected input immediately after a previous call.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called after the previous call.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - previousCall: A previous function call that must come immediately before the matching call.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: The matching function call, or `nil` if no matching call was found.
    @discardableResult
    static func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning: Output.Type? = nil,
        immediatelyAfter previousCall: (any FunctionCall),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConcreteFunctionCall<Input, Output>? {
        blackBox.assertWasCalled(function, signature: signature, immediatelyAfter: previousCall, file: file, line: line)
    }

}

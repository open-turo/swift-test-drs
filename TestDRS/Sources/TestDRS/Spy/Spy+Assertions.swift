//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// swiftformat:disable spaceAroundOperators

// MARK: - Instance methods

/// Extension for `Spy` that provides assertion methods for verifying call counts and call order.
public extension Spy {

    /// Asserts that the given function was called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: An `AssertWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
    @discardableResult
    func assertWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AssertWasCalledResult<MatchingAnyAmount, Input, Output> {
        blackBox.assertWasCalled(function, signature: signature, file: file, line: line)
    }

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
    /// - Returns: An `AssertWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
    @discardableResult
    func assertWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AssertWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> where repeat each Input: Equatable {
        blackBox.assertWasCalled(function, signature: signature, expectedInput: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the given function was not called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was not called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    func assertWasNotCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        blackBox.assertWasNotCalled(function, signature: signature, file: file, line: line)
    }

}

// TODO: The static versions of each method could be generated by a macro.

// MARK: - Static methods

/// Extension for `Spy` that provides assertion methods for verifying call counts and call order.
public extension Spy {

    /// Asserts that the given function was called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    /// - Returns: An `AssertWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
    @discardableResult
    static func assertStaticFunctionWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AssertWasCalledResult<MatchingAnyAmount, Input, Output> {
        blackBox.assertWasCalled(function, signature: signature, file: file, line: line)
    }

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
    /// - Returns: An `AssertWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
    @discardableResult
    static func assertStaticFunctionWasCalled<each Input, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: String,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AssertWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> where repeat each Input: Equatable {
        blackBox.assertWasCalled(function, signature: signature, expectedInput: repeat each expectedInput, file: file, line: line)
    }

    /// Asserts that the given function was not called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to assert was not called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - file: **Do not pass in this argument**, it will automatically capture the file path where the assertion is being made.
    ///   - line: **Do not pass in this argument**, it will automatically capture the line number where the assertion is being made.
    static func assertStaticFunctionWasNotCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: String,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        blackBox.assertWasNotCalled(function, signature: signature, file: file, line: line)
    }

}

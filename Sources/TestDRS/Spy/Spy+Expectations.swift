//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

// swiftformat:disable spaceAroundOperators

public enum ExpectedCallMode {
    /// Calls made to a function other than those expected should cause a failure
    case exclusive
    /// Calls made to a function other than those expected should not cause a failure
    case nonExclusive
}

// MARK: - Instance methods

/// Extension for `Spy` that provides expectation methods for verifying call counts and call order.
public extension Spy {

    /// Expects that the given function was called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to expect was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - mode: The `ExpectedCallMode` to use when verifying fuction calls. Defaults to `exclusive`, where non-matching calls to the function cause a failure.
    /// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
    @discardableResult
    func expectWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        mode: ExpectedCallMode = .exclusive,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> ExpectWasCalledResult<MatchingAnyAmount, Input, Output> {
        let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        return blackBox.expectWasCalled(
            function,
            signature: signature,
            mode: mode,
            location: location
        )
    }

    /// Expects that the given function was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to expect was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
    ///   - mode: The `ExpectedCallMode` to use when verifying fuction calls. Defaults to `exclusive`, where non-matching calls to the function cause a failure.
    /// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
    @discardableResult
    func expectWasCalled<each Input: Equatable, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        mode: ExpectedCallMode = .exclusive,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> ExpectWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> {
        let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        return blackBox.expectWasCalled(
            function,
            signature: signature,
            expectedInput: repeat each expectedInput,
            mode: mode,
            location: location
        )
    }

    /// Expects that the given function was not called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to expect was not called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    func expectWasNotCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        blackBox.expectWasNotCalled(
            function,
            signature: signature,
            location: location
        )
    }

}

// TODO: The static versions of each method could be generated by a macro.

// MARK: - Static methods

/// Extension for `Spy` that provides expectation methods for verifying call counts and call order.
public extension Spy {

    /// Expects that the given function was called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to expect was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    ///   - mode: The `ExpectedCallMode` to use when verifying fuction calls. Defaults to `exclusive`, where non-matching calls to the function cause a failure.
    /// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
    @discardableResult
    static func expectStaticFunctionWasCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        mode: ExpectedCallMode = .exclusive,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> ExpectWasCalledResult<MatchingAnyAmount, Input, Output> {
        let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        return getStaticBlackBox(location: location)
            .expectWasCalled(
                function,
                signature: signature,
                mode: mode,
                location: location
            )
    }

    /// Expects that the given function was called with the expected input.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to expect was called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - expectedInput: The expected input parameter(s) for the function.
    ///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
    ///   - mode: The `ExpectedCallMode` to use when verifying fuction calls. Defaults to `exclusive`, where non-matching calls to the function cause a failure.
    /// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
    @discardableResult
    static func expectStaticFunctionWasCalled<each Input: Equatable, Output>(
        _ function: (repeat each Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        expectedInput: repeat each Input,
        returning: Output.Type? = nil,
        mode: ExpectedCallMode = .exclusive,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) -> ExpectWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> {
        let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        return getStaticBlackBox(location: location)
            .expectWasCalled(
                function,
                signature: signature,
                expectedInput: repeat each expectedInput,
                mode: mode,
                location: location
            )
    }

    /// Expects that the given function was not called.
    ///
    /// - Parameters:
    ///   - function: A reference to the function to expect was not called.
    ///   - signature: The signature of the function to check.
    ///   The signature can be obtained by right-clicking on the function's signature and selecting "Copy" > "Copy Symbol Name".
    ///   This should also match what is recorded by the `#function` macro.
    ///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
    ///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
    static func expectStaticFunctionWasNotCalled<Input, Output>(
        _ function: (Input) async throws -> Output,
        withSignature signature: FunctionSignature,
        taking inputType: Input.Type? = nil,
        returning outputType: Output.Type? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let location = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        return getStaticBlackBox(location: location)
            .expectWasNotCalled(
                function,
                signature: signature,
                location: location
            )
    }

}

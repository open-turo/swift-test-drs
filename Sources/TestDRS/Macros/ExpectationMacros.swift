//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

// MARK: - expectWasCalled

/// Expects that the given function was called.
///
/// - Parameters:
///   - function: A reference to the function to expect was called.
///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
/// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
@freestanding(expression)
@discardableResult
public macro expectWasCalled<Input, Output>(
    _ function: (Input) async throws -> Output,
    taking inputType: Input.Type? = nil,
    returning outputType: Output.Type? = nil
) -> ExpectWasCalledResult<MatchingAnyAmount, Input, Output> = #externalMacro(module: "TestDRSMacros", type: "ExpectWasCalledMacro")


/// Expects that the given function was called with the expected input.
///
/// - Parameters:
///   - function: A reference to the function to expect was called.
///   - expectedInput: The expected input parameter(s) for the function.
///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
/// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
@freestanding(expression)
@discardableResult
public macro expectWasCalled<each Input, Output>(
    _ function: (repeat each Input) async throws -> Output,
    with expectedInput: repeat each Input,
    returning outputType: Output.Type? = nil
) -> ExpectWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> = #externalMacro(module: "TestDRSMacros", type: "ExpectWasCalledMacro") where repeat each Input: Equatable

// MARK: - expectWasNotCalled

/// Expects that the given function was not called.
///
/// - Parameters:
///   - function: A reference to the function to expect was not called.
///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
@freestanding(expression)
@discardableResult
public macro expectWasNotCalled<Input, Output>(
    _ function: (Input) async throws -> Output,
    taking inputType: Input.Type? = nil,
    returning outputType: Output.Type? = nil
) = #externalMacro(module: "TestDRSMacros", type: "ExpectWasNotCalledMacro")

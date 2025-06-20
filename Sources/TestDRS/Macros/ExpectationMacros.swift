//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

// swiftformat:disable spaceAroundOperators

// MARK: - expectWasCalled

/// Expects that the given function was called.
///
/// - Parameters:
///   - function: A reference to the function to expect was called.
///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
///   - mode: The `ExpectedCallMode` to use when verifying fuction calls. Defaults to `exclusive`, where non-matching calls to the function cause a failure.
/// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
@freestanding(expression)
@discardableResult
public macro expectWasCalled<Input, Output>(
    _ function: (Input) async throws -> Output,
    taking inputType: Input.Type? = nil,
    returning outputType: Output.Type? = nil,
    mode: ExpectedCallMode = .exclusive
) -> ExpectWasCalledResult<MatchingAnyAmount, Input, Output> = #externalMacro(module: "TestDRSMacros", type: "ExpectWasCalledMacro")

/// Expects that the given function was called with the expected input.
///
/// - Parameters:
///   - function: A reference to the function to expect was called.
///   - expectedInput: The expected input parameter(s) for the function.
///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
///   - mode: The `ExpectedCallMode` to use when verifying fuction calls. Defaults to `exclusive`, where non-matching calls to the function cause a failure.
/// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
@freestanding(expression)
@discardableResult
public macro expectWasCalled<each Input: Equatable, Output>(
    _ function: (repeat each Input) async throws -> Output,
    with expectedInput: repeat each Input,
    returning outputType: Output.Type? = nil,
    mode: ExpectedCallMode = .exclusive
) -> ExpectWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> = #externalMacro(module: "TestDRSMacros", type: "ExpectWasCalledMacro")

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

// MARK: - expectCase

/// Expects that the given value matches the specified enum case.
///
/// This macro generates a switch statement that verifies the enum value matches the expected case pattern.
/// If the case doesn't match, it reports a test failure with a descriptive error message.
///
/// - Parameters:
///   - expectedCase: The expected case pattern (e.g., `.success`, `.failure(_)`, `.loading(progress: _)`).
///   - value: The enum value to check against the expected case.
///
/// Example usage:
/// ```swift
/// enum Result<T, E> {
///     case success(T)
///     case failure(E)
/// }
///
/// let result: Result<String, Error> = .success("data")
/// #expectCase(.success(_), in: result)  // Passes
/// #expectCase(.failure(_), in: result)  // Fails with descriptive message
/// ```
@freestanding(expression)
public macro expectCase<T>(
    _ expectedCase: T,
    in value: T
) = #externalMacro(module: "TestDRSMacros", type: "ExpectCaseMacro")

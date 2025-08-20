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
/// This macro verifies the enum value matches the expected case pattern.
/// If the case doesn't match, it reports a test failure with a descriptive error message.
///
/// - Parameters:
///   - expectedCase: The expected case pattern (e.g., `.success(_)`, `.failure("error")`)
///   - value: The enum value to check against the expected case
///
/// Example usage:
/// ```swift
/// enum Result<T, E> {
///     case success(T)
///     case failure(E)
/// }
///
/// let result: Result<String, Error> = .success("data")
/// #expectCase(Result.success, in: result)   // ✅ Passes - matches any success
/// #expectCase(.success("data"), in: result) // ✅ Passes with specific value
/// #expectCase(Result.failure, in: result)   // ❌ Fails with descriptive message
/// ```
@freestanding(expression)
public macro expectCase<T>(
    _ expectedCase: T,
    in value: T
) = #externalMacro(module: "TestDRSMacros", type: "ExpectCaseMacro")

/// Expects that the given value matches the specified enum case constructor, ignoring associated values.
///
/// This overload allows matching enum cases without specifying their associated values by using
/// the enum case constructor directly (e.g., `MyEnum.someCase`). This is useful when you want
/// to verify that a value is a specific case but don't care about the associated values.
///
/// - Parameters:
///   - expectedCase: The enum case constructor (e.g., `Result.success`, `MyEnum.loading`)
///   - value: The enum value to check against the expected case
///
/// - Note: You must specify the full enum type name (e.g., `Result.success`) rather than
///   the shorthand syntax (`.success`) because Swift needs the type information to properly
///   resolve the case constructor function type.
///
/// Example usage:
/// ```swift
/// enum LoadingState<T> {
///     case idle
///     case loading(progress: Double)
///     case loaded(T)
///     case error(String)
/// }
///
/// let state: LoadingState<String> = .loading(progress: 0.75)
///
/// // ✅ Matches any loading state regardless of progress value
/// #expectCase(LoadingState.loading, in: state)
///
/// // ✅ Matches specific progress value
/// #expectCase(.loading(progress: 0.75), in: state)
///
/// // ❌ Would fail - different case
/// #expectCase(LoadingState.idle, in: state)
/// ```
@freestanding(expression)
public macro expectCase<T, each U>(
    _ expectedCase: (repeat each U) -> T,
    in value: T
) = #externalMacro(module: "TestDRSMacros", type: "ExpectCaseMacro")

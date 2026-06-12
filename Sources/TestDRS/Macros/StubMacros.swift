//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

/// Sets a stub for a given function to return a provided output.
///
/// - Parameters:
///   - function: The function to stub. The specified function must be a member of a `StubProviding` type.
///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
///   - output: The output value to be returned when the function is called.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(
    _ function: (Input) async throws -> Output,
    taking inputType: Input.Type? = nil,
    returning output: Output
) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubReturningOutputMacro")

/// Sets a stub for a given function to throw a provided error.
///
/// - Parameters:
///   - function: The function to stub. The specified function must be a member of a `StubProviding` type.
///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
///   - outputType: An optional phantom parameter used to specify the output type of the `function` passed in.
///   This is useful for functions that are generic over their output or have overloads that differ only by their output type,
///   where the output type cannot otherwise be inferred when throwing an error.
///   - error: The error to be thrown when the function is called.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(
    _ function: (Input) async throws -> Output,
    taking inputType: Input.Type? = nil,
    returning outputType: Output.Type? = nil,
    throwing error: Error
) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubThrowingErrorMacro")

/// Sets a stub for a given function using a closure to dynamically determine the output.
///
/// - Parameters:
///   - function: The function to stub. The specified function must be a member of a `StubProviding` type.
///   - closure: A closure that takes in the function's input and returns the desired output when the function is called.
///
///   - Note: Macros do not seem to support trailing syntax currently, so you must specify the argument label `using`.
///   This also serves to disambiguate from `stub(_:returning:)` where the `Output` is a closure.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(_ function: (Input) async throws -> Output, using closure: (Input) throws -> Output) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubUsingClosureMacro")

/// Sets a stub for a given function using an async closure to dynamically determine the output.
///
/// - Parameters:
///   - function: The function to stub. The specified function must be a member of a `StubProviding` type.
///   - closure: An async closure that takes in the function's input and returns the desired output when the function is called.
///
///   - Note: Macros do not seem to support trailing syntax currently, so you must specify the argument label `using`.
///   This also serves to disambiguate from `stub(_:returning:)` where the `Output` is a closure.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(_ function: (Input) async throws -> Output, using closure: (Input) async throws -> Output) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubUsingClosureMacro")

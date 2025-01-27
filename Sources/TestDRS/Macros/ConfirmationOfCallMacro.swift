//
// Created on 1/13/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import Foundation

/// Awaits confirmation of a function call.
///
/// Similar to using a `Confirmation` in Swift Testing, this macro allows you to await confirmation that a function was called in
/// scenarios where you can't await the function directly.
///
/// - Parameters:
///   - function: A reference to the function to expect was called.
///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
///   - timeLimit: The maximum amount of time to wait for confirmation. If the time limit is reached before the first call can be confirmed, a test failure is reported. Defaults to a duration that is effectively infinite.
/// - Returns: A `FunctionCallConfirmation` that waits for the first matching call. Further calls can be confirmed by calling methods on this confirmation.
@available(iOS 16.0, *)
@freestanding(expression)
@discardableResult
public macro confirmationOfCall<Input, Output>(
    to function: (Input) async throws -> Output,
    taking inputType: Input.Type? = nil,
    returning outputType: Output.Type? = nil,
    timeLimit: Duration = .maxTimeLimit,
    isolation: isolated(any Actor)? = #isolation
) -> FunctionCallConfirmation<MatchingFirst, Input, Output> = #externalMacro(module: "TestDRSMacros", type: "ConfirmationOfCallMacro")


/// Awaits confirmation of a function call with an expected input.
///
/// Similar to using a `Confirmation` in Swift Testing, this macro allows you to await confirmation that a function was called in
/// scenarios where you can't await the function directly.
///
/// - Parameters:
///   - function: A reference to the function to expect was called.
///   - expectedInput: The expected input parameter(s) for the function.
///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
///   - timeLimit: The maximum amount of time to wait for confirmation. If the time limit is reached before the first call can be confirmed, a test failure is reported. Defaults to a duration that is effectively infinite.
/// - Returns: A `FunctionCallConfirmation` that waits for the first matching call. Further calls can be confirmed by calling methods on this confirmation.
@available(iOS 16.0, *)
@freestanding(expression)
@discardableResult
public macro confirmationOfCall<each Input: Equatable, Output>(
    to function: (repeat each Input) async throws -> Output,
    with expectedInput: repeat each Input,
    returning outputType: Output.Type? = nil,
    timeLimit: Duration = .maxTimeLimit,
    isolation: isolated(any Actor)? = #isolation
) -> FunctionCallConfirmation<MatchingFirst, (repeat each Input), Output> = #externalMacro(module: "TestDRSMacros", type: "ConfirmationOfCallMacro")

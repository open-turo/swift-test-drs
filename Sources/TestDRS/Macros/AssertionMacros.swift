//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

public typealias AssertWasCalledResult = ExpectWasCalledResult

// MARK: - assertWasCalled

/// Asserts that the given function was called. __Intended for use with `XCTest`. For use with Swift `Testing`, see `expectWasCalled`.__
///
/// - Parameters:
///   - function: A reference to the function to assert was called.
///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
/// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
@freestanding(expression)
@discardableResult
public macro assertWasCalled<Input, Output>(
    _ function: (Input) async throws -> Output,
    taking inputType: Input.Type? = nil,
    returning outputType: Output.Type? = nil
) -> AssertWasCalledResult<MatchingAnyAmount, Input, Output> = #externalMacro(module: "TestDRSMacros", type: "AssertWasCalledMacro")


/// Asserts that the given function was called with the expected input. __Intended for use with `XCTest`. For use with Swift `Testing`, see `expectWasCalled`.__
///
/// - Parameters:
///   - function: A reference to the function to assert was called.
///   - expectedInput: The expected input parameter(s) for the function.
///   - outputType: An optional phantom parameter used to derive the output type of the `function` passed in.
/// - Returns: An `ExpectWasCalledResult` containing the matching function calls, or an empty array if no matching call was found.
@freestanding(expression)
@discardableResult
public macro assertWasCalled<each Input, Output>(
    _ function: (repeat each Input) async throws -> Output,
    with expectedInput: repeat each Input,
    returning outputType: Output.Type? = nil
) -> AssertWasCalledResult<MatchingAnyAmount, (repeat each Input), Output> = #externalMacro(module: "TestDRSMacros", type: "AssertWasCalledMacro") where repeat each Input: Equatable

// MARK: - assertWasNotCalled

/// Asserts that the given function was not called. __Intended for use with `XCTest`. For use with Swift `Testing`, see `expectWasNotCalled`.__
///
/// - Parameters:
///   - function: A reference to the function to assert was not called.
///   - inputType: An optional phantom parameter used to derive the input type of the `function` passed in.
///   - outputType: An optional  phantom parameter used to derive the output type of the `function` passed in.
@freestanding(expression)
@discardableResult
public macro assertWasNotCalled<Input, Output>(
    _ function: (Input) async throws -> Output,
    taking inputType: Input.Type? = nil,
    returning outputType: Output.Type? = nil
) = #externalMacro(module: "TestDRSMacros", type: "AssertWasNotCalledMacro")

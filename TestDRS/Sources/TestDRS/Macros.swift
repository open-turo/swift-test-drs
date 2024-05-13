//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

/// This macro generates a mock type based on a given protocol, class, or struct.
///
/// The generated mock type includes methods that mimic the original type's interface, allowing you to control its behavior in tests.
/// For a given type `MyType`, the generated mock type will be named `MockMyType`.
/// The mock type will conform to the `StubProviding` and `Spy` protocols. This allows you to stub out each method and assert that methods were called in your tests.
/// Classes will be mocked using a subclass, while protocols and structs will be mocked using a separate class.
/// Private members are not included in the generated mock type.
/// Static members of a class will not be included in the generated mock type as they cannot be overridden.
///
/// Usage:
/// ```
/// @Mock
/// protocol MyType {
///     func myMethod()
/// }
/// ```
///
/// This will generate a `MockMyType` with the following structure:
/// ```
/// #if DEBUG
///
/// class MockMyType: MyType, Spy, StubProviding {
///     func myMethod() {
///         // Implementation for stubbing and spying
///     }
/// }
///
/// #endif
/// ```
///
/// - Note: The generated mock type will be wrapped in an `#if DEBUG` directive, meaning it will only be included in Debug builds.
/// This ensures that mock types are not included in production code.
/// The generated mock type is intended for use in unit tests, during development, in SwiftUI previews, etc.
@attached(peer, names: prefixed(Mock))
public macro Mock() = #externalMacro(module: "TestDRSMacros", type: "MockMacro")

/// Sets a stub for a given function to return a provided output.
///
/// - Parameters:
///   - function: The function to stub. The specified function must be a member of a `StubProviding` type.
///   - output: The output value to be returned when the function is called.
///
///   - Note: The compiler will not be able to disambiguate when stubbing functions that are overloaded *and* share the same output type.
///   If that is the case, use `#stub(_:using:)` and specify the input to the closure explicitly.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(_ function: (Input) async throws -> Output, returning output: Output) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubReturningOutputMacro")

/// Sets a stub for a given function to throw a provided error.
///
/// - Parameters:
///   - function: The function to stub. The specified function must be a member of a `StubProviding` type.
///   - error: The error to be thrown when the function is called.
///
///   - Note: The compiler will not be able to disambiguate when stubbing functions that are overloaded *and* share the same output type.
///   If that is the case, use `#stub(_:using:)` and specify the input to the closure explicitly.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(_ function: (Input) async throws -> Output, throwing error: Error) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubThrowingErrorMacro")

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

// MARK: - Spy Assertion Macros

/// Asserts that the function specified was called.
///
/// When passing in a reference to a function, only the fact that the function was called will be asserted. If a function call is passed in, the fact that the function was called with the same arguments that were passed in will be asserted.
///
/// - Parameters:
///   - functionOrCall: Either a reference to a function as in `mock.foo` or `mock.bar(paramOne:)` or a function call like `mock.foo()` or `mock.bar(paramOne: "Hello World")`. The specified function must be a member of a `Spy`.
/// - Returns: The first matching function call, or `nil` if no matching call was found.
@freestanding(expression)
@discardableResult
public macro assertWasCalled<T>(_ functionOrCall: T) -> (any FunctionCall)? = #externalMacro(module: "TestDRSMacros", type: "AssertWasCalledMacro")

/// Asserts that the function specified was the first to be called.
///
/// When passing in a reference to a function, only the fact that the function was called will be asserted. If a function call is passed in, the fact that the function was called with the same arguments that were passed in will be asserted.
///
/// - Parameters:
///   - functionOrCall: Either a reference to a function as in `mock.foo` or `mock.bar(paramOne:)` or a function call like `mock.foo()` or `mock.bar(paramOne: "Hello World")`. The specified function must be a member of a `Spy`.
/// - Returns: The first matching function call, or `nil` if no matching call was found.
@freestanding(expression)
@discardableResult
public macro assertWasCalledFirst<T>(_ functionOrCall: T) -> (any FunctionCall)? = #externalMacro(module: "TestDRSMacros", type: "AssertWasCalledFirstMacro")

/// Asserts that the function specified was the last to be called.
///
/// When passing in a reference to a function, only the fact that the function was called will be asserted. If a function call is passed in, the fact that the function was called with the same arguments that were passed in will be asserted.
///
/// - Parameters:
///   - functionOrCall: Either a reference to a function as in `mock.foo` or `mock.bar(paramOne:)` or a function call like `mock.foo()` or `mock.bar(paramOne: "Hello World")`. The specified function must be a member of a `Spy`.
/// - Returns: The first matching function call, or `nil` if no matching call was found.
@freestanding(expression)
@discardableResult
public macro assertWasCalledLast<T>(_ functionOrCall: T) -> (any FunctionCall)? = #externalMacro(module: "TestDRSMacros", type: "AssertWasCalledLastMacro")

/// Asserts that the function specified was called exactly once.
///
/// When passing in a reference to a function, only the fact that the function was called will be asserted. If a function call is passed in, the fact that the function was called with the same arguments that were passed in will be asserted.
///
/// - Parameters:
///   - functionOrCall: Either a reference to a function as in `mock.foo` or `mock.bar(paramOne:)` or a function call like `mock.foo()` or `mock.bar(paramOne: "Hello World")`. The specified function must be a member of a `Spy`.
/// - Returns: The first matching function call, or `nil` if no matching call was found.
@freestanding(expression)
@discardableResult
public macro assertWasCalledExactlyOnce<T>(_ functionOrCall: T) -> (any FunctionCall)? = #externalMacro(module: "TestDRSMacros", type: "AssertWasCalledExactlyOnceMacro")

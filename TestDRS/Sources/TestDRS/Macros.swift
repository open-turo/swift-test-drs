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

/// Sets a stub for a given method to return a provided output.
///
/// - Parameters:
///   - method: The method to stub.
///   - output: The output value to be returned when the method is called.
///
///   - Note: The compiler will not be able to disambiguate when stubbing methods that are overloaded *and* share the same output type.
///   If that is the case, use `#stub(_:using:)` and specify the input to the closure explicitly.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(_ method: (Input) async throws -> Output, returning output: Output) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubReturningOutputMacro")

/// Sets a stub for a given method to throw a provided error.
///
/// - Parameters:
///   - method: The method to stub.
///   - error: The error to be thrown when the method is called.
///
///   - Note: The compiler will not be able to disambiguate when stubbing methods that are overloaded *and* share the same output type.
///   If that is the case, use `#stub(_:using:)` and specify the input to the closure explicitly.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(_ method: (Input) async throws -> Output, throwing error: Error) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubThrowingErrorMacro")

/// Sets a stub for a given method using a closure to dynamically determine the output.
///
/// - Parameters:
///   - method: The method to stub.
///   - closure: A closure that takes in the method's input and returns the desired output when the method is called.
///
///   - Note: Macros do not seem to support trailing syntax currently, so you must specify the argument label `using`.
///   This also serves to disambiguate from `stub(_:returning:)` where the `Output` is a closure.
@freestanding(expression)
@discardableResult
public macro stub<Input, Output>(_ method: (Input) async throws -> Output, using closure: (Input) throws -> Output) -> Void = #externalMacro(module: "TestDRSMacros", type: "SetStubUsingClosureMacro")

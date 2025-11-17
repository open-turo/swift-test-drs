//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

/// This macro generates a spy type based on a given protocol, class, or struct.
///
/// The generated spy type delegates all calls to a real object instance while recording
/// those calls for verification in tests. For a given type `MyType`, the generated spy
/// type will be named `SpyMyType`. The spy type will conform to the `Spy` protocol,
/// which provides call recording and verification capabilities.
///
/// Unlike mocks, spies do not stub behavior - they delegate to a real implementation
/// and must be initialized with a real object.
///
/// ## Spy Generation Rules:
/// - Classes will be spied using a subclass that overrides methods and delegates to `super`
/// - Protocols and structs will be spied using a separate class/struct wrapper that delegates to a real instance
/// - Private members are not included in the generated spy type
/// - Final classes cannot be spied (as they cannot be subclassed)
/// - Final members of a class cannot be spied (as they cannot be overridden)
///
/// ## Member Handling:
/// - Spy classes will override all non-private, non-final instance members
/// - Static members of a class will not be included in the spy as they cannot be overridden
/// - Protocol and struct spies will include all non-private members
///
/// ## Initializer Handling:
/// - **Class spies**: Use the parent class initializers (no `init(real:)` is generated)
/// - **Protocol/struct spies**: Require an `init(real:)` initializer that accepts the real object to delegate to
///
/// ## Protocol Spy Example:
/// ```
/// @AddSpy
/// protocol MyService {
///     func myMethod()
/// }
/// ```
///
/// This will generate a `SpyMyService` that wraps a real instance:
/// ```
/// #if DEBUG
/// class SpyMyService<RealType: MyService>: MyService, Spy {
///     let blackBox = BlackBox(mockType: SpyMyService.self)
///     private let real: RealType
///
///     init(real: RealType) {
///         self.real = real
///     }
///
///     func myMethod() {
///         recordCall()
///         real.myMethod()
///     }
/// }
/// #endif
/// ```
///
/// ## Class Spy Example:
/// ```
/// @AddSpy
/// class MyService {
///     func myMethod() { /* implementation */ }
/// }
/// ```
///
/// This will generate a `SpyMyService` subclass that delegates to `super`:
/// ```
/// #if DEBUG
/// class SpyMyService: MyService, Spy {
///     let blackBox = BlackBox(mockType: SpyMyService.self)
///
///     override func myMethod() {
///         recordCall()
///         super.myMethod()
///     }
/// }
/// #endif
/// ```
///
/// - Note: The generated spy type will be wrapped in an `#if DEBUG` directive, meaning it will only be included in Debug builds.
/// This ensures that spy types are not included in production code.
/// The generated spy type is intended for use in unit tests, during development, in SwiftUI previews, etc.
@attached(peer, names: prefixed(Spy))
public macro AddSpy() = #externalMacro(module: "TestDRSMacros", type: "AddSpyMacro")

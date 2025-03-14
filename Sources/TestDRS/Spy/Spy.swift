//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A protocol that enables observing and verifying function calls during testing.
///
/// The `Spy` protocol provides a mechanism for recording function calls, including their
/// parameters and timing, which can then be verified in tests. This allows for
/// interaction-based testing, where you verify that your code interacts correctly with
/// its dependencies.
///
/// Types conforming to `Spy` can:
/// - Record when functions are called and what arguments were passed
/// - Verify that specific functions were called the expected number of times
/// - Verify that functions were called with specific arguments
/// - Confirm calls asynchronously, useful for testing code with concurrency
/// - Test both instance methods and static methods
///
/// `Spy` functionality is commonly used together with stubbing (via `StubProviding`) in test doubles
/// to create full-featured mocks (via the `Mock` protocol).
///
/// Macros like `@AddMock` can automatically generate types that implement this protocol.
///
/// Example usage:
/// ```swift
/// @AddMock
/// protocol UserService {
///     func fetchUser(withID id: String) async throws -> User
/// }
///
/// func testFetchUserIsCalled() async {
///     // Create a mock that conforms to Spy
///     let mockUserService = MockUserService()
///     
///     // Use mock in code under test
///     let userViewModel = UserViewModel(userService: mockUserService)
///     await userViewModel.loadUser(id: "user123")
///     
///     // Verify the method was called with expected input
///     #expectWasCalled(mockUserService.fetchUser, with "user123")
/// }
/// ```
public protocol Spy: StaticTestable {
    /// The storage mechanism for recorded function calls.
    ///
    /// The `blackBox` stores all function calls made to the spy, allowing for later verification.
    var blackBox: BlackBox { get }
}

public extension Spy {

    /// Records a function call along with its details for later verification.
    ///
    /// This method is typically called within mock implementations of methods to record that the method
    /// was called, with what parameters, and when. This information can later be used in tests to verify
    /// that the code under test interacted with the mock as expected.
    ///
    /// When mocks are generated using using a macro like `@AddMock` or `@Mock`, calls to this method are automatically
    /// inserted into the mock implementations of functions.
    ///
    /// - Parameters:
    ///   - input: The parameter(s) passed to the function. For functions with multiple parameters, 
    ///          use a tuple containing all parameters in the order they appear in the function signature.
    ///          For functions without parameters, this defaults to `Void()`.
    ///   - time: The time when the function was called. Defaults to the current time.
    ///   - outputType: The return type of the function. For void functions, this defaults to `Void.self`.
    ///   - signature: The signature of the function that was called. **Do not pass in this argument**,
    ///              it will automatically capture the signature of the calling function using `#function`.
    ///
    /// Example usage within a mock implementation:
    /// ```swift
    /// func fetchUser(withID id: String) async throws -> User {
    ///     recordCall(with: id)
    ///     return try await throwingStubOutput(for: id)
    /// }
    /// ```
    func recordCall<Input, Output>(
        with input: Input = Void(),
        at time: Date = Date(),
        returning outputType: Output.Type = Void.self,
        signature: FunctionSignature = #function
    ) {
        blackBox.recordCall(
            with: input,
            at: time,
            returning: outputType,
            signature: signature
        )
    }

    /// Records a static function call along with its details for later verification.
    ///
    /// This method is the static counterpart to  the`recordCall` instance method and is used
    /// to record calls to static methods. It works similarly to the instance method version, but is designed
    /// for static context.
    ///
    /// When static method mocks are generated using a macro like `@AddMock` or `@Mock`, calls to this method are automatically
    /// inserted into the mock implementations of static functions.
    ///
    /// - Parameters:
    ///   - input: The parameter(s) passed to the static function. For functions with multiple parameters, 
    ///          use a tuple containing all parameters in the order they appear in the function signature.
    ///          For functions without parameters, this defaults to `Void()`.
    ///   - time: The time when the function was called. Defaults to the current time.
    ///   - outputType: The return type of the function. For void functions, this defaults to `Void.self`.
    ///   - signature: The signature of the function that was called. **Do not pass in this argument**,
    ///              it will automatically capture the signature of the calling function using `#function`.
    ///
    /// - Note: To test static methods, you'll need to use the `withStaticTestingContext` function to create
    ///       a testing context that isolates the static state between tests.
    ///
    /// Example usage within a static mock implementation:
    /// ```swift
    /// static func fetchDefaultUser() async throws -> User {
    ///     recordCall()
    ///     return try await throwingStubOutput()
    /// }
    /// ```
    static func recordCall<Input, Output>(
        with input: Input = Void(),
        at time: Date = Date(),
        returning outputType: Output.Type = Void.self,
        signature: FunctionSignature = #function
    ) {
        getStaticBlackBox(location: nil).recordCall(
            with: input,
            at: time,
            returning: outputType,
            signature: signature
        )
    }

}

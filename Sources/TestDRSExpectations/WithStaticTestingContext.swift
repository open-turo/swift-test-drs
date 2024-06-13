//
// Created on 6/12/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@_spi(Internal) import TestDRSMocking

/// Creates a `StaticTestingContext` for testing the given `StaticTestable` types during the duration of the operation.
///
/// Testing static members can be challenging because they maintain their state across tests.
/// This can lead to side effects where the outcome of one test affects another, leading to flaky tests that pass or fail unpredictably.
/// Using `withStaticTestingContext` ensures that each test starts with a clean slate and does not have a dependency on any other test.
///
/// When using `XCTest`, you can wrap the contents of your test like so:
///
/// ```swift
/// class MyTests: XCTestCase {
///
///   func myTest() {
///       withStaticTestingContext {
///           // Test some static member
///       }
///   }
///
/// }
/// ```
/// If all of the tests in a test case will be testing static members, you can wrap `invokeTest` so that a new static testing context
/// is created for every test method:
///
/// ```swift
/// class MyTests: XCTestCase {
///
///   override func invokeTest() {
///       withStaticTestingContext {
///           super.invokeTest()
///       }
///   }
///
/// }
/// ```
///
/// - Note: `withStaticTestingContext` employs a task-local variable to maintain the current static testing context. This ensures thread-safety within the Swift Concurrency model.
/// However, detached `Task`s and non-Swift Concurrency code won't have access to this context. Consequently, static calls within these contexts cannot be tested.
///
/// - Parameters:
///   - operation: The operation to run with the static testing context configured to test the given types.
@discardableResult
public func withStaticTestingContext<R>(operation: () throws -> R) rethrows -> R {
    try StaticTestingContext.$current.withValue(StaticTestingContext()) {
        try operation()
    }
}

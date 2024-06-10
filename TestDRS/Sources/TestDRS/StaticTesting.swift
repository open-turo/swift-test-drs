//
// Created on 6/7/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Creates a `StaticTestingContext` for testing the given `StaticTestable` types during the duration of the operation.
///
/// Testing static members can be challenging because they maintain their state across tests.
/// This can lead to side effects where the outcome of one test affects another, leading to flaky tests that pass or fail unpredictably.
/// Using `withStaticTestingContext` ensures that each test starts with a clean slate and does not have a dependency on any other test.
///
/// The most convenient way to use `withStaticTestingContext` is to wrap `invokeTest` in an `XCTestCase` subclass so that a new static testing context
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
    var context = StaticTestingContext()

    return try StaticTestingContext.$current.withValue(context) {
        try operation()
    }
}

/// A type whose static members can be tested using a `StaticTestingContext`.
public protocol StaticTestable {
    /// Registers the type with the static testing context.
    static func register(with context: inout StaticTestingContext)
}

extension StaticTestable where Self: Spy {
    public static func register(with context: inout StaticTestingContext) {
        context.registerBlackBox(for: Self.self)
    }
}

extension StaticTestable where Self: StubProviding {
    public static func register(with context: inout StaticTestingContext) {
        context.registerStubRegistry(for: Self.self)
    }
}

extension StaticTestable where Self: Mock {
    public static func register(with context: inout StaticTestingContext) {
        context.registerBlackBox(for: Self.self)
        context.registerStubRegistry(for: Self.self)
    }
}

public class StaticTestingContext {
    @TaskLocal static var current: StaticTestingContext?

    var blackBoxes: [String: BlackBox] = [:]
    var stubRegistries: [String: StubRegistry] = [:]

    func registerBlackBox<T>(for type: T.Type) {
        let key = String(describing: type)
        blackBoxes[key] = BlackBox()
    }

    func blackBox<T>(for type: T.Type) -> BlackBox {
        let key = String(describing: type)

        if let blackBox = blackBoxes[key] {
            return blackBox
        }

        let blackBox = BlackBox()
        blackBoxes[key] = blackBox
        return blackBox
    }

    func registerStubRegistry<T>(for type: T.Type) {
        let key = String(describing: type)
        stubRegistries[key] = StubRegistry()
    }

    func stubRegistry<T>(for type: T.Type) -> StubRegistry {
        let key = String(describing: type)

        if let stubRegistry = stubRegistries[key] {
            return stubRegistry
        }

        let stubRegistry = StubRegistry()
        stubRegistries[key] = stubRegistry
        return stubRegistry
    }
}

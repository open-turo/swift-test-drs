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

public class StaticTestingContext: @unchecked Sendable {

    @TaskLocal static var current: StaticTestingContext?

    /// Used to make the `StaticTestingContext` thread-safe.
    private let storageQueue = DispatchQueue(label: "StaticTestingContextQueue")

    private var blackBoxes: [String: BlackBox] = [:]
    private var stubRegistries: [String: StubRegistry] = [:]

    func registerBlackBox<T>(for type: T.Type) {
        storageQueue.sync {
            let key = String(describing: type)
            blackBoxes[key] = BlackBox()
        }
    }

    func blackBox<T>(for type: T.Type) -> BlackBox {
        storageQueue.sync {
            let key = String(describing: type)
            if let blackBox = blackBoxes[key] {
                return blackBox
            }

            let blackBox = BlackBox()
            blackBoxes[key] = blackBox
            return blackBox
        }
    }

    func registerStubRegistry<T>(for type: T.Type) {
        storageQueue.sync {
            let key = String(describing: type)
            stubRegistries[key] = StubRegistry()
        }
    }

    func stubRegistry<T>(for type: T.Type) -> StubRegistry {
        storageQueue.sync {
            let key = String(describing: type)
            if let stubRegistry = stubRegistries[key] {
                return stubRegistry
            }

            let stubRegistry = StubRegistry()
            stubRegistries[key] = stubRegistry
            return stubRegistry
        }
    }

}

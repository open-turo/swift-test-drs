//
// Created on 6/7/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

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

    @TaskLocal @_spi(Internal) public static var current: StaticTestingContext?

    /// Used to make the `StaticTestingContext` thread-safe.
    private let storageQueue = DispatchQueue(label: "StaticTestingContextQueue")

    private var blackBoxes: [String: BlackBox] = [:]
    private var stubRegistries: [String: StubRegistry] = [:]

    @_spi(Internal) public init() {}

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

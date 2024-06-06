//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

public extension StubProviding {

    static func register(staticStubRegistry: StubRegistry) {
        StubRegistry.register(staticStorage: staticStubRegistry, for: Self.self)
    }

    static func getStaticStubRegistry() -> StubRegistry {
        guard let stubRegistry = StubRegistry.staticStorage(for: Self.self) else {
            fatalError("You must generate a static testing token using `\(Self.self).generateStaticTestingToken()` and hold on to it for the duration of the test in order to utilize StubProviding functionality with static members of \(Self.self).")
        }

        return stubRegistry
    }

}

// MARK: - StubRegistry + StaticStorageRegistering
extension StubRegistry: StaticStorageRegistering {

    static var staticStorageRegistry: [String: WeakWrapper<StubRegistry>] = [:]

}

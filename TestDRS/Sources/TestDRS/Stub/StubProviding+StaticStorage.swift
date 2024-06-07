//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension StubProviding {

    static func getStaticStubRegistry() -> StubRegistry {
        guard let stubRegistry = StaticTestingContext.current.stubRegistry(for: Self.self) else {
            fatalError("""
            \(Self.self) was not registered with the current StaticTestingContext. You can register it by wrapping invokeTest in an XCTestCase subclass like so:

            override func invokeTest() {
                withStaticTestingContext(testing: [\(Self.self).self]) {
                    super.invokeTest()
                }
            }
            """)
        }

        return stubRegistry
    }

}

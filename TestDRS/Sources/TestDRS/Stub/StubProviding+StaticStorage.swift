//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension StubProviding {

    static func getStaticStubRegistry() -> StubRegistry {
        guard let context = StaticTestingContext.current else {
            fatalError("""
            Unable to resolve the current StaticTestingContext. You can create one in an XCTestCase subclass by wrapping invokeTest like so:

            override func invokeTest() {
                withStaticTestingContext(testing: [\(Self.self).self]) {
                    super.invokeTest()
                }
            }
            """)
        }

        guard let stubRegistry = context.stubRegistry(for: Self.self) else {
            fatalError("\(Self.self) was not registered with the current StaticTestingContext. Did you forget to include it in the testable types when calling withStaticTestingContext?")
        }

        return stubRegistry
    }

}

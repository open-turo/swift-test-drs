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
                withStaticTestingContext {
                    super.invokeTest()
                }
            }
            """)
        }

        return context.stubRegistry(for: Self.self)
    }

}

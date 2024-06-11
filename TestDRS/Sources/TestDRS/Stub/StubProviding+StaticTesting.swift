//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension StubProviding {

    static func getStaticStubRegistry() -> StubRegistry {
        guard let context = StaticTestingContext.current else {
            fatalError("""
            Unable to resolve the current StaticTestingContext. You can create one by wrapping your test with a call to withStaticTestingContext:

            withStaticTestingContext {
              // Test some static member
            }
            """)
        }

        return context.stubRegistry(for: Self.self)
    }

}

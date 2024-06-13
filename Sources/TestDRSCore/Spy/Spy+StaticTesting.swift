//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension Spy {

    @_spi(Internal)
    public static func getStaticBlackBox() -> BlackBox {
        guard let context = StaticTestingContext.current else {
            assertionFailure("""
            Unable to resolve the current StaticTestingContext. You can create one by wrapping your test with a call to withStaticTestingContext:

            withStaticTestingContext {
                // Test some static member
            }
            """)
            return BlackBox()
        }

        return context.blackBox(for: Self.self)
    }

}

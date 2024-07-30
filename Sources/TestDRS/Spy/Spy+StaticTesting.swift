//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension Spy {

    static func getStaticBlackBox(location: SourceLocation?) -> BlackBox {
        guard let context = StaticTestingContext.current else {
            let message = """
            Unable to resolve the current StaticTestingContext. You can create one by wrapping your test with a call to withStaticTestingContext:

            withStaticTestingContext {
                // Test some static member
            }
            """

            if let location {
                reportFailure(message, location: location)
            } else {
                reportFailure(message)
            }

            return BlackBox()
        }

        return context.blackBox(for: Self.self)
    }

}

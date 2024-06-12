//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension Spy {

    static func getStaticBlackBox(file: StaticString? = nil, line: UInt? = nil) -> BlackBox {
        guard let context = StaticTestingContext.current else {
            let blackBox = BlackBox()
            blackBox.reportFailure(
                message: """
                Unable to resolve the current StaticTestingContext. You can create one by wrapping your test with a call to withStaticTestingContext:

                withStaticTestingContext {
                    // Test some static member
                }
                """,
                file: file,
                line: line
            )
            return blackBox
        }

        return context.blackBox(for: Self.self)
    }

}

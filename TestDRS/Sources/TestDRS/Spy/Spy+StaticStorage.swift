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
                Unable to resolve the current StaticTestingContext. You can create one in an XCTestCase subclass by wrapping invokeTest like so:

                override func invokeTest() {
                    withStaticTestingContext(testing: [\(Self.self).self]) {
                        super.invokeTest()
                    }
                }
                """,
                file: file,
                line: line
            )
            return blackBox
        }

        guard let blackBox = context.blackBox(for: Self.self) else {
            let blackBox = BlackBox()
            blackBox.reportFailure(
                message: "\(Self.self) was not registered with the current StaticTestingContext. Did you forget to include it in the testable types when calling withStaticTestingContext?",
                file: file,
                line: line
            )
            return blackBox
        }

        return blackBox
    }

}

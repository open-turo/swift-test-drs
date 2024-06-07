//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension Spy {

    static func getStaticBlackBox(file: StaticString? = nil, line: UInt? = nil) -> BlackBox {
        guard let blackBox = StaticTestingContext.current.blackBox(for: Self.self) else {
            let blackBox = BlackBox()
            blackBox.reportFailure(
                message: """
                \(Self.self) was not registered with the current StaticTestingContext. You can register it by wrapping invokeTest in an XCTestCase subclass like so:

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

        return blackBox
    }

}

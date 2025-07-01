//
// Created on 7/1/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS

@Mock
private struct MultiLineStub {
    func foo() -> String

    init() {
        // Testing by virtue of this stub compiling
        #stub(
            foo,
            returning: "bar"
        )
    }
}

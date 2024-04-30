//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import XCTestDynamicOverlay

extension Spy {

    /// Reports a test failure with a custom message, file, and line number.
    ///
    /// - Parameters:
    ///   - message: The custom failure message.
    ///   - file: The file where the failure occurred.
    ///   - line: The line number where the failure occurred.
    public func reportFailure(message: String, file: StaticString, line: UInt) {
        XCTFail(message, file: file, line: line)
    }

}

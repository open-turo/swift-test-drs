//
// Created on 6/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// The location in source code where an event occurred, used to attribute a test failure to a location in code.
public struct SourceLocation {
    let fileID: StaticString
    let filePath: StaticString
    let line: UInt
    let column: UInt
}

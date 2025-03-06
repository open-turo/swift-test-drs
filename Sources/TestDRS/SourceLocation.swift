//
// Created on 6/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// The location in source code where an event occurred, used to attribute a test failure to a location in code.
///
/// This structure is used to capture the precise location in the source code where a test assertion or verification
/// was made. When a test failure occurs, this information is used to report the exact file, line, and column where
/// the failing code is located, making it easier to locate and fix issues.
public struct SourceLocation {
    /// The identifier of the file containing the source location, typically provided by the `#fileID` literal.
    /// This is a shorter form of the file path used in compiler diagnostics.
    let fileID: StaticString
    
    /// The full path of the file containing the source location, typically provided by the `#file` literal.
    /// This provides the complete filesystem path to the source file.
    let filePath: StaticString
    
    /// The line number in the source file where the event occurred, typically provided by the `#line` literal.
    /// Line numbers start at 1 for the first line of the file.
    let line: UInt
    
    /// The column number in the source file where the event occurred, typically provided by the `#column` literal.
    /// Column numbers start at 1 for the first character of the line.
    let column: UInt
}

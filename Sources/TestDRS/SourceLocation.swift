//
// Created on 6/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// The location in source code where an event occurred, used to attribute a test failure to a location in code.
public struct SourceLocation {

    public var fileID: String { String(describing: _fileID) }
    public var filePath: String { String(describing: _filePath) }
    public var line: Int { Int(_line) }
    public var column: Int { Int(_column) }

    public var xctFile: StaticString { _filePath }
    public var xctLine: UInt { _line }

    private let _fileID: StaticString
    private let _filePath: StaticString
    private let _line: UInt
    private let _column: UInt

    init(
        fileID: StaticString,
        filePath: StaticString,
        line: UInt,
        column: UInt
    ) {
        _fileID = fileID
        _filePath = filePath
        _line = line
        _column = column
    }

}

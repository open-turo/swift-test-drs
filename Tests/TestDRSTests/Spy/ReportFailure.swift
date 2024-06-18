//
// Created on 6/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing
import XCTest

/// `XCTest` compatible failure reporting function
nonisolated(unsafe) let xctReportFailure: ReportFailure = { message, location in
    XCTFail(message, file: location.xctFile, line: location.xctLine)
}

/// Swift `Testing` compatible failure reporting function
nonisolated(unsafe) let stReportFailure: ReportFailure = { message, location in
    Issue.record(
        Comment(rawValue: message),
        fileID: location.fileID,
        filePath: location.filePath,
        line: location.line,
        column: location.column
    )
}

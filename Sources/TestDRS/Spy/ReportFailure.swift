//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Used by expectation macros which inject a function that handles reporting any test failures.
/// This allows TestDRS to not depend on `XCTest` or Swift `Testing`.
public typealias ReportFailure = (String, SourceLocation) -> Void

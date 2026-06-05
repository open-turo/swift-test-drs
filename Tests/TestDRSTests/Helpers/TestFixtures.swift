//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Common error type for testing error handling
struct TestError: Error, Equatable {}

/// Common test data structure
struct TestData: Equatable {
    let id: String
    let value: Int
}

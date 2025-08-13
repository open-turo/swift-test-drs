//
// Created on 8/12/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS

// Verifying that @objc protocol mocks compile with proper override keywords by lack of build errors.

@AddMock
@objc public protocol SomeObjectiveCProtocol {
    init()
    init(value: String)
    func performAction()
}

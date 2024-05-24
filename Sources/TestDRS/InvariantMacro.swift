//
// Created on 5/24/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

@freestanding(expression)
@discardableResult
public macro invariant(_ invariant: Bool) = #externalMacro(module: "TestDRSMacros", type: "InvariantMacro")

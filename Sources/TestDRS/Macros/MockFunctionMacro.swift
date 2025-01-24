//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Mocks the body of a function, intended for internal use only.
@attached(body)
public macro _MockFunction() = #externalMacro(module: "TestDRSMacros", type: "MockFunctionMacro")

//
// Created on 5/27/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Mocks a property, intended for internal use only.
@attached(accessor)
public macro _MockProperty() = #externalMacro(module: "TestDRSMacros", type: "MockPropertyMacro")

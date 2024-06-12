//
// Created on 5/27/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// This macro is intended for use by the `AddMockMacro` to provide custom accessors.
/// It should not be applied manually to properties.
@attached(accessor)
public macro __MockProperty() = #externalMacro(module: "TestDRSMacros", type: "MockPropertyMacro")

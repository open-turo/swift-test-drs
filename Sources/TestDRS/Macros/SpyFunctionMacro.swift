//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Generates spy function body that records calls and delegates to real object, intended for internal use only.
/// - Parameter delegateTypeName: Type name for static member delegation (e.g., "RealType" for protocols, concrete type for structs/classes)
@attached(body)
public macro _SpyFunction(_ delegateTypeName: String) = #externalMacro(module: "TestDRSMacros", type: "SpyFunctionMacro")

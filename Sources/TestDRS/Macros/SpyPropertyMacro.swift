//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Generates spy property accessors that delegate to real object, intended for internal use only.
/// - Parameter accessors: The accessor type - "get" for read-only or "get set" for read-write
/// - Parameter delegateTypeName: Type name for static member delegation (e.g., "RealType" for protocols, concrete type for structs/classes)
@attached(accessor)
public macro _SpyProperty(_ accessors: String, _ delegateTypeName: String) = #externalMacro(module: "TestDRSMacros", type: "SpyPropertyMacro")

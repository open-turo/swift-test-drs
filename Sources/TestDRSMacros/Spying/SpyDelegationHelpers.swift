//
// Created on 11/15/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

/// Determines the delegation target for spy members based on member characteristics
func spyDelegationTarget(
    isOverride: Bool,
    isClassMember: Bool,
    isStaticMember: Bool,
    delegateTypeName: String
) -> String {
    if isClassMember || isOverride {
        // Class members (class func) and overridden methods (class spies) use super
        return "super"
    } else if isStaticMember {
        // Static members use the delegate type
        return delegateTypeName
    } else {
        // Instance members on protocol/struct spies use real
        return "real"
    }
}

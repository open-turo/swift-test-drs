//
// Created on 5/3/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension InheritanceClauseSyntax {

    static var emptyClause: InheritanceClauseSyntax {
        InheritanceClauseSyntax(inheritedTypes: [])
    }

    /// Appends the given types to the inheritance clause syntax.
    ///
    /// - Parameters:
    ///    - types: An array of strings representing the types to be appended.
    ///
    /// - Returns: An updated `InheritanceClauseSyntax` with the appended types.
    func appending(_ types: [String]) -> InheritanceClauseSyntax {
        let typeList = InheritedTypeListSyntax {
            for existingType in inheritedTypes.trimmed {
                existingType
            }
            for type in types {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(type)))
            }
        }
        return with(\.inheritedTypes, typeList)
    }

}

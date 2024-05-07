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
        var typeList = inheritedTypes.trimmed

        if var lastType = typeList.last, let lastIndex = typeList.index(of: lastType) {
            lastType.trailingComma = .commaToken()
            typeList[lastIndex] = lastType
        }

        types.enumerated().forEach { index, type in
            typeList.append(
                InheritedTypeSyntax(
                    leadingTrivia: [],
                    type: IdentifierTypeSyntax(name: .identifier(type)),
                    trailingComma: index == types.count - 1 ? nil : .commaToken()
                )
            )
        }

        var clause = self
        clause.inheritedTypes = typeList
        return clause
    }

}

//
// Created on 5/3/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension DeclModifierListSyntax {
    /// Checks if the `DeclModifierListSyntax` contains a specific keyword.
    ///
    /// - Parameters:
    ///   - keyword: The keyword to search for.
    ///
    /// - Returns: `true` if the `DeclModifierListSyntax` contains the specified keyword, `false` otherwise.
    func containsKeyword(_ keyword: Keyword) -> Bool {
        contains(where: { $0.name.tokenKind == .keyword(keyword) })
    }
}

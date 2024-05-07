//
// Created on 5/3/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension IfConfigDeclSyntax {

    static func ifDebug(@MemberBlockItemListBuilder wrapping declarations: () throws -> MemberBlockItemListSyntax) throws -> IfConfigDeclSyntax {
        let decls = try MemberBlockItemListSyntax(itemsBuilder: declarations)
        return IfConfigDeclSyntax(
            clauses: IfConfigClauseListSyntax {
                IfConfigClauseSyntax(
                    poundKeyword: .poundIfToken(),
                    condition: DeclReferenceExprSyntax(baseName: .identifier("DEBUG")),
                    elements: .decls(decls)
                )
            },
            poundEndif: .poundEndifToken()
        )
    }

}

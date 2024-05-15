//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension MemberAccessExprSyntax {
    var resolvedArguments: DeclNameArgumentsSyntax {
        declName.argumentNames ?? DeclNameArgumentsSyntax(arguments: .init())
    }
}

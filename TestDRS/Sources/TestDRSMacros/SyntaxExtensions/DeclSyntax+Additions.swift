//
// Created on 5/7/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import SwiftSyntax

extension DeclSyntax {
    var isTypeDeclaration: Bool {
        self.as(ProtocolDeclSyntax.self) != nil ||
            self.as(EnumDeclSyntax.self) != nil ||
            self.as(StructDeclSyntax.self) != nil ||
            self.as(ClassDeclSyntax.self) != nil ||
            self.as(ActorDeclSyntax.self) != nil
    }
}

//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@attached(peer, names: prefixed(Mock))
public macro Mock() = #externalMacro(module: "TestDRSMacros", type: "MockMacro")

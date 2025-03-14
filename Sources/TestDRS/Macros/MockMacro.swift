//
// Created on 6/20/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// This macro mocks the members of the struct or class that it is applied to.
///
/// Properties of the attached type should not be initialized inline (using an initializer is allowed, but not required)
/// and functions should not have bodies.
/// In most circumstances the attached type should conform to a protocol,
/// so an easy way to generate the member definitions is to just apply the fixit that pops up after adopting the protocol
/// and then delete the empty bodies of the functions.
///
/// This macro adds conformance to the `StubProviding` and `Spy` protocols. This allows you to stub out each method and expect that methods were called in your tests.
@attached(extension, conformances: Mock)
@attached(member, conformances: Mock, names: named(blackBox), named(stubRegistry))
@attached(memberAttribute)
public macro Mock() = #externalMacro(module: "TestDRSMacros", type: "MockMacro")

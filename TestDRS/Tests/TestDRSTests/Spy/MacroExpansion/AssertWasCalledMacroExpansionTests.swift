//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
@testable import TestDRSMacros
import XCTest

final class AssertWasCalledMacroExpansionTests: XCTestCase {

    var assertionMacro: AssertMethodOrCallMacro.Type!

    // Cycle through each assertion for every test.
    override func invokeTest() {
        let assertionMacros: [AssertMethodOrCallMacro.Type] = [
            AssertWasCalledMacro.self,
            AssertWasCalledExactlyOnceMacro.self,
            AssertWasCalledFirstMacro.self,
            AssertWasCalledLastMacro.self,
        ]

        assertionMacros.forEach { assertionMacro in
            self.assertionMacro = assertionMacro
            withMacroTesting(macros: [assertionMacro.name: assertionMacro]) {
                super.invokeTest()
            }
        }
    }

    func testAssertionWithMethod_WithNoMemberAccess_WithNoArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(foo)
            """
        } expansion: {
            """
            \(self.assertionMacro.name)("foo()")
            """
        }
    }

    func testAssertionWithMethod_WithMemberAccess_WithNoArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(mock.foo)
            """
        } expansion: {
            """
            mock.\(self.assertionMacro.name)("foo()")
            """
        }
    }

    func testAssertionWithMethod_WithNestedMemberAccess_WithNoArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(base.mock.foo)
            """
        } expansion: {
            """
            base.mock.\(self.assertionMacro.name)("foo()")
            """
        }
    }

    func testAssertionWithMethod_WithNoMemberAccess_WithSingleArgument() {
        assertMacro {
            """
            #\(assertionMacro.name)(foo(paramOne:))
            """
        } expansion: {
            """
            \(self.assertionMacro.name)("foo(paramOne:)")
            """
        }
    }

    func testAssertionWithMethod_WithMemberAccess_WithSingleArgument() {
        assertMacro {
            """
            #\(assertionMacro.name)(mock.foo(paramOne:))
            """
        } expansion: {
            """
            mock.\(self.assertionMacro.name)("foo(paramOne:)")
            """
        }
    }

    func testAssertionWithMethod_WithNestedMemberAccess_WithSingleArgument() {
        assertMacro {
            """
            #\(assertionMacro.name)(base.mock.foo(paramOne:))
            """
        } expansion: {
            """
            base.mock.\(self.assertionMacro.name)("foo(paramOne:)")
            """
        }
    }

    func testAssertionWithMethod_WithNoMemberAccess_WithMultipleArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(foo(_:paramTwo:))
            """
        } expansion: {
            """
            \(self.assertionMacro.name)("foo(_:paramTwo:)")
            """
        }
    }

    func testAssertionWithMethod_WithMemberAccess_WithMultipleArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(mock.foo(_:paramTwo:))
            """
        } expansion: {
            """
            mock.\(self.assertionMacro.name)("foo(_:paramTwo:)")
            """
        }
    }

    func testAssertionWithMethod_WithNestedMemberAccess_WithMultipleArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(base.mock.foo(_:paramTwo:))
            """
        } expansion: {
            """
            base.mock.\(self.assertionMacro.name)("foo(_:paramTwo:)")
            """
        }
    }

    func testAssertionWithCall_WithNoMemberAccess_WithNoArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(foo())
            """
        } expansion: {
            """
            \(self.assertionMacro.name)("foo()")
            """
        }
    }

    func testAssertionWithCall_WithMemberAccess_WithNoArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(mock.foo())
            """
        } expansion: {
            """
            mock.\(self.assertionMacro.name)("foo()")
            """
        }
    }

    func testAssertionWithCall_WithNestedMemberAccess_WithNoArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(base.mock.foo())
            """
        } expansion: {
            """
            base.mock.\(self.assertionMacro.name)("foo()")
            """
        }
    }

    func testAssertionWithCall_WithNoMemberAccess_WithSingleArgument() {
        assertMacro {
            """
            #\(assertionMacro.name)(foo(paramOne: "Hello World"))
            """
        } expansion: {
            """
            \(self.assertionMacro.name)("foo(paramOne:)", with: "Hello World")
            """
        }
    }

    func testAssertionWithCall_WithMemberAccess_WithSingleArgument() {
        assertMacro {
            """
            #\(assertionMacro.name)(mock.foo(paramOne: "Hello World"))
            """
        } expansion: {
            """
            mock.\(self.assertionMacro.name)("foo(paramOne:)", with: "Hello World")
            """
        }
    }

    func testAssertionWithCall_WithNestedMemberAccess_WithSingleArgument() {
        assertMacro {
            """
            #\(assertionMacro.name)(base.mock.foo(paramOne: "Hello World"))
            """
        } expansion: {
            """
            base.mock.\(self.assertionMacro.name)("foo(paramOne:)", with: "Hello World")
            """
        }
    }

    func testAssertionWithCall_WithNoMemberAccess_WithMultipleArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(foo("Hello World", paramTwo: 7))
            """
        } expansion: {
            """
            \(self.assertionMacro.name)("foo(_:paramTwo:)", with: "Hello World", 7)
            """
        }
    }

    func testAssertionWithCall_WithMemberAccess_WithMultipleArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(mock.foo("Hello World", paramTwo: 7))
            """
        } expansion: {
            """
            mock.\(self.assertionMacro.name)("foo(_:paramTwo:)", with: "Hello World", 7)
            """
        }
    }

    func testAssertionWithCall_WithNestedMemberAccess_WithMultipleArguments() {
        assertMacro {
            """
            #\(assertionMacro.name)(base.mock.foo("Hello World", paramTwo: 7))
            """
        } expansion: {
            """
            base.mock.\(self.assertionMacro.name)("foo(_:paramTwo:)", with: "Hello World", 7)
            """
        }
    }

}

#endif

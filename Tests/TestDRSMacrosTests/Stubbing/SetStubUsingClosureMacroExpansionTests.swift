//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class SetStubUsingClosureMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["stub": SetStubUsingClosureMacro.self]) {
            super.invokeTest()
        }
    }

    func testStubbingMethod_WithNoArguments() {
        assertMacro {
            """
            #stub(mock.foo, using: { "Hello World" })
            """
        } diagnostics: {
            """

            """
        } expansion: {
            """
            mock.setDynamicStub(for: mock.foo, withSignature: "foo", using: {
                    "Hello World"
                })
            """
        }
    }

    func testStubbingMethod_WithArguments() {
        assertMacro {
            """
            #stub(mock.foo(_:paramTwo:), using: { "Hello World" })
            """
        } expansion: {
            """
            mock.setDynamicStub(for: mock.foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)", using: {
                    "Hello World"
                })
            """
        }
    }

    func testStubbingMethod_WithNoBase_WithNoArguments() {
        assertMacro {
            """
            #stub(foo, using: { "Hello World" })
            """
        } expansion: {
            """
            setDynamicStub(for: foo, withSignature: "foo", using: {
                    "Hello World"
                })
            """
        }
    }

    func testStubbingMethod_WithNoBase_WithArguments() {
        assertMacro {
            """
            let x = "Hello "
            let y = "World"
            #stub(foo(_:paramTwo:), using: { x + y })
            """
        } expansion: {
            """
            let x = "Hello "
            let y = "World"
            setDynamicStub(for: foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)", using: {
                    x + y
                })
            """
        }
    }

    func testStubbingMethod_WithClosureVariable() {
        assertMacro {
            """
            let block = { "Hello World" }
            #stub(mock.foo, using: block)
            """
        } expansion: {
            """
            let block = { "Hello World" }
            mock.setDynamicStub(for: mock.foo, withSignature: "foo", using: block)
            """
        }
    }

    func testStubbingMethod_WithMultilineFormatting() {
        assertMacro {
            """
            #stub(
                foo,
                using: { "Hello World" }
            )
            """
        } expansion: {
            """
            setDynamicStub(for: foo, withSignature: "foo", using: {
                    "Hello World"
                })
            """
        }
    }

    func testStubbingMethod_WithMultilineFormatting_WithArguments() {
        assertMacro {
            """
            #stub(
                foo(_:paramTwo:),
                using: { "Hello World" }
            )
            """
        } expansion: {
            """
            setDynamicStub(for: foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)", using: {
                    "Hello World"
                })
            """
        }
    }

}

#endif

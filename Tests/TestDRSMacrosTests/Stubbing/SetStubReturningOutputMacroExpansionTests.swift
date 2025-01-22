//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class SetStubReturningOutputMacroTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["stub": SetStubReturningOutputMacro.self]) {
            super.invokeTest()
        }
    }

    func testStubbingMethod_WithNoArguments() {
        assertMacro {
            """
            #stub(mock.foo, returning: "Hello World")
            """
        } expansion: {
            """
            mock.setStub(for: mock.foo, withSignature: "foo", taking: nil, returning: "Hello World")
            """
        }
    }

    func testStubbingMethod_WithArguments() {
        assertMacro {
            """
            #stub(mock.foo(_:paramTwo:), returning: "Hello World")
            """
        } expansion: {
            """
            mock.setStub(for: mock.foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)", taking: nil, returning: "Hello World")
            """
        }
    }

    func testStubbingMethod_WithNoBase_WithNoArguments() {
        assertMacro {
            """
            #stub(foo, returning: "Hello World")
            """
        } expansion: {
            """
            setStub(for: foo, withSignature: "foo()", taking: nil, returning: "Hello World")
            """
        }
    }

    func testStubbingMethod_WithNoBase_WithArguments() {
        assertMacro {
            """
            #stub(foo(_:paramTwo:), returning: "Hello World")
            """
        } expansion: {
            """
            setStub(for: foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)", taking: nil, returning: "Hello World")
            """
        }
    }

    func testStubbingMethod_WithInputTypeSpecified() {
        assertMacro {
            """
            #stub(foo, taking: Int.self, returning: "Hello World")
            """
        } expansion: {
            """
            setStub(for: foo, withSignature: "foo()", taking: Int.self, returning: "Hello World")
            """
        }
    }

}

#endif

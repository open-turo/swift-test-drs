//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
import TestDRSMacros
import XCTest

final class SetStubThrowingErrorMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: ["stub": SetStubThrowingErrorMacro.self]) {
            super.invokeTest()
        }
    }

    func testStubbingMethod_WithNoArguments() {
        assertMacro {
            """
            #stub(mock.foo, throwing: MyError.someError)
            """
        } expansion: {
            """
            mock.setStub(for: mock.foo, withSignature: "foo", taking: nil, returning: nil, throwing: MyError.someError)
            """
        }
    }

    func testStubbingMethod_WithArguments() {
        assertMacro {
            """
            #stub(mock.foo(_:paramTwo:), throwing: MyError.someError)
            """
        } expansion: {
            """
            mock.setStub(for: mock.foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)", taking: nil, returning: nil, throwing: MyError.someError)
            """
        }
    }

    func testStubbingMethod_WithNoBase_WithNoArguments() {
        assertMacro {
            """
            #stub(foo, throwing: MyError.someError)
            """
        } expansion: {
            """
            setStub(for: foo, withSignature: "foo", taking: nil, returning: nil, throwing: MyError.someError)
            """
        }
    }

    func testStubbingMethod_WithNoBase_WithArguments() {
        assertMacro {
            """
            #stub(foo(_:paramTwo:), throwing: MyError.someError)
            """
        } expansion: {
            """
            setStub(for: foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)", taking: nil, returning: nil, throwing: MyError.someError)
            """
        }
    }

    func testStubbingMethod_WithInputTypeSpecified() {
        assertMacro {
            """
            #stub(foo, taking: Int.self, throwing: MyError.someError)
            """
        } expansion: {
            """
            setStub(for: foo, withSignature: "foo", taking: Int.self, returning: nil, throwing: MyError.someError)
            """
        }
    }

    func testStubbingMethod_WithOutputTypeSpecified() {
        assertMacro {
            """
            #stub(foo, returning: String.self, throwing: MyError.someError)
            """
        } expansion: {
            """
            setStub(for: foo, withSignature: "foo", taking: nil, returning: String.self, throwing: MyError.someError)
            """
        }
    }

    func testStubbingMethod_WithInputAndOutputTypeSpecified() {
        assertMacro {
            """
            #stub(foo, taking: Int.self, returning: String.self, throwing: MyError.someError)
            """
        } expansion: {
            """
            setStub(for: foo, withSignature: "foo", taking: Int.self, returning: String.self, throwing: MyError.someError)
            """
        }
    }

    func testStubbingMethod_WithMultilineFormatting() {
        assertMacro {
            """
            #stub(
                foo,
                throwing: MyError.someError
            )
            """
        } expansion: {
            """
            setStub(for: foo, withSignature: "foo", taking: nil, returning: nil, throwing: MyError.someError)
            """
        }
    }

    func testStubbingMethod_WithMultilineFormatting_WithArguments() {
        assertMacro {
            """
            #stub(
                foo(_:paramTwo:),
                taking: Int.self,
                throwing: MyError.someError
            )
            """
        } expansion: {
            """
            setStub(for: foo(_:paramTwo:), withSignature: "foo(_:paramTwo:)", taking: Int.self, returning: nil, throwing: MyError.someError)
            """
        }
    }

}

#endif

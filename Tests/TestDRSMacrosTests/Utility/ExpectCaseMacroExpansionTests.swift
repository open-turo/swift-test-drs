//
// Created on 6/6/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

#if canImport(TestDRSMacros)

import MacroTesting
@testable import TestDRSMacros
import XCTest

final class ExpectCaseMacroExpansionTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(macros: [
            "expectCase": ExpectCaseMacro.self
        ]) {
            super.invokeTest()
        }
    }

    // MARK: - #expectCase

    func testExpectCaseMacro_WithSimpleCase() {
        assertMacro {
            """
            #expectCase(.bar, in: foo)
            """
        } expansion: {
            """
            {
                switch foo {
                case .bar:
                    break
                default:
                    _expectCaseFailure(expectedCase: ".bar", actualValue: foo)
                }
            }()
            """
        }
    }

    func testExpectCaseMacro_WithCaseWithSpecificValue() {
        assertMacro {
            """
            #expectCase(.failure("error"), in: result)
            """
        } expansion: {
            """
            {
                switch result {
                case .failure("error"):
                    break
                default:
                    _expectCaseFailure(expectedCase: #".failure("error")"#, actualValue: result)
                }
            }()
            """
        }
    }

    func testExpectCaseMacro_WithInvalidCasePattern() {
        assertMacro {
            """
            #expectCase(someVariable, in: foo)
            """
        } diagnostics: {
            """
            #expectCase(someVariable, in: foo)
                        ┬────────────
                        ╰─ 🛑 #expectCase requires the first argument to be a case pattern (e.g., .caseName)
            """
        }
    }
}

#endif

//
// Created on 5/21/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Expectations
import SharedTesting
import XCTest

final class SpyAssertionMacroTests: SpyTestCase {

    // MARK: - assertWasCalled

    func testAssertWasCalled_WithoutCalling() {
        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(foo)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(foo, taking: Void.self)
        }
    }

    func testAssertWasCalled_WithNoParameters() {
        foo()
        #assertWasCalled(foo)
    }

    func testAssertWasCalled_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        #assertWasCalled(zab(paramOne:), with: true)
        #assertWasCalled(zab(paramOne:), with: "Hello")
        #assertWasCalled(zab(paramOne:), with: "World")
        #assertWasCalled(zab(paramOne:), with: 1)
        #assertWasCalled(zab(paramOne:), with: 2)
        #assertWasCalled(zab(paramOne:), with: 3)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(zab(paramOne:), taking: Double.self)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(zab(paramOne:), with: 1.0)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(zab(paramOne:), with: false)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(zab(paramOne:), with: "Goodbye")
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(zab(paramOne:), with: 4)
        }
    }

    func testAssertWasCalled_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: false, paramTwo: nil, paramThree: nil)

        #assertWasCalled(rab(paramOne:paramTwo:paramThree:), with: true, 1, "Hello")
        #assertWasCalled(rab(paramOne:paramTwo:paramThree:), with: false, Int?.none, String?.none)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(rab(paramOne:paramTwo:paramThree:), with: true, 2, "Hello")
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasCalled(rab(paramOne:paramTwo:paramThree:), with: true, Int?.none, String?.none)
        }
    }

    // MARK: - assertWasNotCalled

    func testAssertWasNotCalled_WithoutCalling() {
        #assertWasNotCalled(foo)
        #assertWasNotCalled(bar(paramOne:))
    }

    func testAssertWasNotCalled_WithCall() {
        foo()

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasNotCalled(foo)
        }
    }

    func testAssertWasNotCalled_WithDifferentInputAndOutputTypes() {
        zab(paramOne: true)
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 1.0)

        #assertWasNotCalled(zab(paramOne:), returning: String.self)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #assertWasNotCalled(zab(paramOne:), returning: Int.self)
        }
    }

}

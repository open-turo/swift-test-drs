//
// Created on 5/21/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class ExpectationMacroTests: SpyTestCase {

    // MARK: - expectWasCalled

    func testExpectWasCalled_WithoutCalling() {
        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(foo)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(foo, taking: Void.self)
        }
    }

    func testExpectWasCalled_WithNoParameters() {
        foo()
        #expectWasCalled(foo)
    }

    func testExpectWasCalled_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        #expectWasCalled(zab(paramOne:), with: true)
        #expectWasCalled(zab(paramOne:), with: "Hello")
        #expectWasCalled(zab(paramOne:), with: "World")
        #expectWasCalled(zab(paramOne:), with: 1)
        #expectWasCalled(zab(paramOne:), with: 2)
        #expectWasCalled(zab(paramOne:), with: 3)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(zab(paramOne:), taking: Double.self)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(zab(paramOne:), with: 1.0)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(zab(paramOne:), with: false)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(zab(paramOne:), with: "Goodbye")
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(zab(paramOne:), with: 4)
        }
    }

    func testExpectWasCalled_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: false, paramTwo: nil, paramThree: nil)

        #expectWasCalled(rab(paramOne:paramTwo:paramThree:), with: true, 1, "Hello")
        #expectWasCalled(rab(paramOne:paramTwo:paramThree:), with: false, Int?.none, String?.none)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(rab(paramOne:paramTwo:paramThree:), with: true, 2, "Hello")
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(rab(paramOne:paramTwo:paramThree:), with: true, Int?.none, String?.none)
        }
    }

    // MARK: - expectWasNotCalled

    func testExpectWasNotCalled_WithoutCalling() {
        #expectWasNotCalled(foo)
        #expectWasNotCalled(bar(paramOne:))
    }

    func testExpectWasNotCalled_WithCall() {
        foo()

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasNotCalled(foo)
        }
    }

    func testExpectWasNotCalled_WithDifferentInputAndOutputTypes() {
        zab(paramOne: true)
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 1.0)

        #expectWasNotCalled(zab(paramOne:), returning: String.self)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasNotCalled(zab(paramOne:), returning: Int.self)
        }
    }

}

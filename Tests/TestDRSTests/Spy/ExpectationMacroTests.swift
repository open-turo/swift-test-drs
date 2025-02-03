//
// Created on 5/21/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class ExpectationMacroTests: XCTestCase {

    private let spy = TestSpy()

    // MARK: - expectWasCalled

    func testExpectWasCalled_WithoutCalling() {
        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.foo)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.foo, taking: Void.self)
        }
    }

    func testExpectWasCalled_WithDifferentParameterTypes() {
        spy.zab(paramOne: true)
        spy.zab(paramOne: "Hello")

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.zab(paramOne:), with: true)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.zab(paramOne:), with: "Hello")
        }
    }

    func testExpectWasCalled_WithDifferentParameterTypes_NonExclusiveMode() {
        spy.zab(paramOne: true)
        spy.zab(paramOne: "Hello")
        spy.zab(paramOne: "World")
        spy.zab(paramOne: 1)
        spy.zab(paramOne: 2)
        spy.zab(paramOne: 3)

        #expectWasCalled(spy.zab(paramOne:), with: true, mode: .nonExclusive)
        #expectWasCalled(spy.zab(paramOne:), with: "Hello", mode: .nonExclusive)
        #expectWasCalled(spy.zab(paramOne:), with: "World", mode: .nonExclusive)
        #expectWasCalled(spy.zab(paramOne:), with: 1, mode: .nonExclusive)
        #expectWasCalled(spy.zab(paramOne:), with: 2, mode: .nonExclusive)
        #expectWasCalled(spy.zab(paramOne:), with: 3, mode: .nonExclusive)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.zab(paramOne:), taking: Double.self, mode: .nonExclusive)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.zab(paramOne:), with: 1.0, mode: .nonExclusive)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.zab(paramOne:), with: false, mode: .nonExclusive)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.zab(paramOne:), with: "Goodbye", mode: .nonExclusive)
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.zab(paramOne:), with: 4, mode: .nonExclusive)
        }
    }

    func testExpectWasCalled_WithMultipleParameters() {
        spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        spy.rab(paramOne: false, paramTwo: nil, paramThree: nil)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.rab(paramOne:paramTwo:paramThree:), with: true, 1, "Hello")
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(spy.rab(paramOne:paramTwo:paramThree:), with: false, nil, nil)
        }
    }

    func testExpectWasCalled_WithMultipleParameters_NonExclusiveMode() {
        spy.rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        spy.rab(paramOne: false, paramTwo: nil, paramThree: nil)

        #expectWasCalled(
            spy.rab(paramOne:paramTwo:paramThree:),
            with: true, 1, "Hello",
            mode: .nonExclusive
        )
        #expectWasCalled(
            spy.rab(paramOne:paramTwo:paramThree:),
            with: false, Int?.none, String?.none,
            mode: .nonExclusive
        )

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(
                spy.rab(paramOne:paramTwo:paramThree:),
                with: true, 2, "Hello",
                mode: .nonExclusive
            )
        }

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasCalled(
                spy.rab(paramOne:paramTwo:paramThree:),
                with: true, Int?.none, String?.none,
                mode: .nonExclusive
            )
        }
    }

    // MARK: - expectWasNotCalled

    func testExpectWasNotCalled_WithoutCalling() {
        #expectWasNotCalled(spy.foo)
        #expectWasNotCalled(spy.bar(paramOne:))
    }

    func testExpectWasNotCalled_WithCall() {
        spy.foo()

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasNotCalled(spy.foo)
        }
    }

    func testExpectWasNotCalled_WithDifferentInputAndOutputTypes() {
        spy.zab(paramOne: true)
        spy.zab(paramOne: 1)
        spy.zab(paramOne: 2)
        spy.zab(paramOne: 1.0)

        #expectWasNotCalled(spy.zab(paramOne:), returning: String.self)

        XCTExpectFailure { [weak self] in
            guard let self else { return }

            #expectWasNotCalled(spy.zab(paramOne:), returning: Int.self)
        }
    }

}

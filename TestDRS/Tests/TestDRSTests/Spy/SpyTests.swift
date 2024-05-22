//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class SpyTests: SpyTestCase {

    func testCallsToFunction_StartsEmpty() {
        let calls = blackBox.callsMatching(signature: "foo()")
        XCTAssertEqual(calls.count, 0)
    }

    func testCallsToFunction_WithNoParameters() {
        foo()
        foo()
        foo()

        let calls = blackBox.callsMatching(signature: "foo()")

        XCTAssertEqual(calls.count, 3)

        XCTAssertEqual(calls[0].time, .functionCallTime(second: 0))
        XCTAssertEqual(calls[0].signature, "foo()")

        XCTAssertEqual(calls[1].time, .functionCallTime(second: 1))
        XCTAssertEqual(calls[1].signature, "foo()")

        XCTAssertEqual(calls[2].time, .functionCallTime(second: 2))
        XCTAssertEqual(calls[2].signature, "foo()")
    }

    func testCallsToFunction_WithSingleParameter() {
        bar(paramOne: true)
        bar(paramOne: false)
        bar(paramOne: true)

        let calls = blackBox.callsMatching(signature: "bar(paramOne:)")

        XCTAssertEqual(calls.count, 3)

        XCTAssertEqual(calls[0].time, .functionCallTime(second: 0))
        XCTAssertEqual(calls[0].signature, "bar(paramOne:)")
        XCTAssertEqual(calls[0].input as? Bool, true)

        XCTAssertEqual(calls[1].time, .functionCallTime(second: 1))
        XCTAssertEqual(calls[1].signature, "bar(paramOne:)")
        XCTAssertEqual(calls[1].input as? Bool, false)

        XCTAssertEqual(calls[2].time, .functionCallTime(second: 2))
        XCTAssertEqual(calls[2].signature, "bar(paramOne:)")
        XCTAssertEqual(calls[2].input as? Bool, true)
    }

    func testCallsToFunction_WithOptionalParameter() {
        baz(paramOne: true)
        baz(paramOne: false)
        baz(paramOne: nil)

        let calls = blackBox.callsMatching(signature: "baz(paramOne:)")

        XCTAssertEqual(calls.count, 3)

        XCTAssertEqual(calls[0].time, .functionCallTime(second: 0))
        XCTAssertEqual(calls[0].signature, "baz(paramOne:)")
        XCTAssertEqual(calls[0].input as? Bool, true)

        XCTAssertEqual(calls[1].time, .functionCallTime(second: 1))
        XCTAssertEqual(calls[1].signature, "baz(paramOne:)")
        XCTAssertEqual(calls[1].input as? Bool, false)

        XCTAssertEqual(calls[2].time, .functionCallTime(second: 2))
        XCTAssertEqual(calls[2].signature, "baz(paramOne:)")
        XCTAssertEqual(calls[2].input as? Bool, Bool?.none)
    }

    func testCallsToFunction_WithTwoParameters() throws {
        oof(paramOne: true, paramTwo: 1)
        oof(paramOne: false, paramTwo: 2)
        oof(paramOne: true, paramTwo: 3)

        let calls = blackBox.callsMatching(signature: "oof(paramOne:paramTwo:)")

        XCTAssertEqual(calls.count, 3)

        XCTAssertEqual(calls[0].time, .functionCallTime(second: 0))
        XCTAssertEqual(calls[0].signature, "oof(paramOne:paramTwo:)")
        let firstInput = try XCTUnwrap(calls[0].input as? (Bool, Int))
        XCTAssertEqual(firstInput.0, true)
        XCTAssertEqual(firstInput.1, 1)

        XCTAssertEqual(calls[1].time, .functionCallTime(second: 1))
        XCTAssertEqual(calls[1].signature, "oof(paramOne:paramTwo:)")
        let secondInput = try XCTUnwrap(calls[1].input as? (Bool, Int))
        XCTAssertEqual(secondInput.0, false)
        XCTAssertEqual(secondInput.1, 2)

        XCTAssertEqual(calls[2].time, .functionCallTime(second: 2))
        XCTAssertEqual(calls[2].signature, "oof(paramOne:paramTwo:)")
        let thirdInput = try XCTUnwrap(calls[2].input as? (Bool, Int))
        XCTAssertEqual(thirdInput.0, true)
        XCTAssertEqual(thirdInput.1, 3)
    }

    func testCallsToFunction_WithThreeParameters() throws {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: false, paramTwo: 2, paramThree: "World")
        rab(paramOne: true, paramTwo: nil, paramThree: nil)

        let calls = blackBox.callsMatching(signature: "rab(paramOne:paramTwo:paramThree:)")

        XCTAssertEqual(calls.count, 3)

        XCTAssertEqual(calls[0].time, .functionCallTime(second: 0))
        XCTAssertEqual(calls[0].signature, "rab(paramOne:paramTwo:paramThree:)")
        let firstInput = try XCTUnwrap(calls[0].input as? (Bool, Int?, String?))
        XCTAssertEqual(firstInput.0, true)
        XCTAssertEqual(firstInput.1, 1)
        XCTAssertEqual(firstInput.2, "Hello")

        XCTAssertEqual(calls[1].time, .functionCallTime(second: 1))
        XCTAssertEqual(calls[1].signature, "rab(paramOne:paramTwo:paramThree:)")
        let secondInput = try XCTUnwrap(calls[1].input as? (Bool, Int?, String?))
        XCTAssertEqual(secondInput.0, false)
        XCTAssertEqual(secondInput.1, 2)
        XCTAssertEqual(secondInput.2, "World")

        XCTAssertEqual(calls[2].time, .functionCallTime(second: 2))
        XCTAssertEqual(calls[2].signature, "rab(paramOne:paramTwo:paramThree:)")
        let thirdInput = try XCTUnwrap(calls[2].input as? (Bool, Int?, String?))
        XCTAssertEqual(thirdInput.0, true)
        XCTAssertEqual(thirdInput.1, nil)
        XCTAssertEqual(thirdInput.2, nil)
    }

    func testCallsToFunction_WithInputAndOutput() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: 1)

        let calls = blackBox.callsMatching(signature: "zab(paramOne:)")

        XCTAssertEqual(calls.count, 3)

        XCTAssertEqual(calls[0].id, 1)
        XCTAssertEqual(calls[0].time, .functionCallTime(second: 0))
        XCTAssertEqual(calls[0].signature, "zab(paramOne:)")
        XCTAssertEqual(calls[0].input as? Bool, true)

        XCTAssertEqual(calls[1].id, 2)
        XCTAssertEqual(calls[1].time, .functionCallTime(second: 1))
        XCTAssertEqual(calls[1].signature, "zab(paramOne:)")
        XCTAssertEqual(calls[1].input as? String, "Hello")

        XCTAssertEqual(calls[2].id, 3)
        XCTAssertEqual(calls[2].time, .functionCallTime(second: 2))
        XCTAssertEqual(calls[2].signature, "zab(paramOne:)")
        XCTAssertEqual(calls[2].input as? Int, 1)
    }

    func testDebugDescription() {
        foo()
        bar(paramOne: true)
        baz(paramOne: nil)
        oof(paramOne: false, paramTwo: 7)

        XCTAssertEqual(
            blackBox.debugDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            """
            ******* Function Call 1 *******
            signature: foo()
            input: ()
            outputType: ()
            time: 2018-06-15 0:00:00.000
            \r******* Function Call 2 *******
            signature: bar(paramOne:)
            input: true
            outputType: ()
            time: 2018-06-15 0:00:01.000
            \r******* Function Call 3 *******
            signature: baz(paramOne:)
            input: nil
            outputType: ()
            time: 2018-06-15 0:00:02.000
            \r******* Function Call 4 *******
            signature: oof(paramOne:paramTwo:)
            input: (false, 7)
            outputType: ()
            time: 2018-06-15 0:00:03.000
            """
        )
    }

    func testDefaultInstanceStorage() {
        let instances = (0 ..< 100).map { $0 }

        for (index, instance) in instances.enumerated() {
            instance.foo(index)
        }

        for (index, instance) in instances.enumerated() {
            #assertWasCalled(instance.foo(_:), with: index)
                .exactlyOnce()
        }
    }

}

// MARK: - Int + Identifiable
extension Int: Identifiable {
    public var id: Int { self }
}

// MARK: - Int + Spy
extension Int: Spy {
    func foo(_ int: Int) {
        recordCall(with: int)
    }
}

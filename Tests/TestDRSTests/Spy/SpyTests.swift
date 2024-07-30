//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class SpyTests: SpyTestCase {

    private let file = #fileID.components(separatedBy: "/").last!
    private var line = 0

    override func invokeTest() {
        withStaticTestingContext {
            super.invokeTest()
        }
    }

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

        // Avoid removal of trailing whitespace
        let space = " "

        XCTAssertEqual(
            blackBox.debugDescription,
            """

            ******* Function Call 1 *******
            signature: "foo()"
            input: ()
            outputType: ()
            time: 2018-06-15 0:00:00.000
            \(space)
            ******* Function Call 2 *******
            signature: "bar(paramOne:)"
            input: true
            outputType: ()
            time: 2018-06-15 0:00:01.000
            \(space)
            ******* Function Call 3 *******
            signature: "baz(paramOne:)"
            input: nil
            outputType: ()
            time: 2018-06-15 0:00:02.000
            \(space)
            ******* Function Call 4 *******
            signature: "oof(paramOne:paramTwo:)"
            input: (false, 7)
            outputType: ()
            time: 2018-06-15 0:00:03.000
            \(space)

            """
        )
    }

    func testCallsToStaticFunction() {
        SpyTestCase.staticFoo()
        SpyTestCase.staticFoo()
        SpyTestCase.staticFoo()

        #expectWasCalled(SpyTestCase.staticFoo)
            .occurring(times: 3)
    }

    func testCallsToStaticFunction_WithinTask() async {
        let exp = XCTestExpectation(description: "Wait for task")

        SpyTestCase.staticFoo()

        Task {
            SpyTestCase.staticFoo()
            exp.fulfill()
        }

        SpyTestCase.staticFoo()

        await fulfillment(of: [exp], timeout: 5)

        #expectWasCalled(SpyTestCase.staticFoo)
            .occurring(times: 3)
    }

    func testCallsToStaticFunction_WithLocalContext() {
        withStaticTestingContext {
            SpyTestCase.staticFoo()
            SpyTestCase.staticFoo()
            MySpy.staticFoo()

            #expectWasCalled(SpyTestCase.staticFoo)
                .occurring(times: 2)
            #expectWasCalled(MySpy.staticFoo)
                .exactlyOnce()
        }
    }

    func testCallsToStaticFunction_WithCallsOutsideNestedLocalContext() {
        // This is convoluted, and I don't expect developers to do this, but we want to make sure it works as expected.
        SpyTestCase.staticFoo()

        withStaticTestingContext {
            SpyTestCase.staticFoo()
            SpyTestCase.staticFoo()
            SpyTestCase.staticFoo()
            SpyTestCase.staticFoo()

            #expectWasCalled(SpyTestCase.staticFoo)
                .occurring(times: 4)
        }

        #expectWasCalled(SpyTestCase.staticFoo)
            .exactlyOnce()
    }

}

private struct MySpy: Spy {
    let blackBox = BlackBox()

    static func staticFoo() {
        recordCall()
    }
}

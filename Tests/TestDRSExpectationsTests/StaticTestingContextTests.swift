//
// Created on 6/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRSCore
import TestDRSExpectations
import XCTest

final class StaticTestingContextTests: SpyTestCase {

    override func invokeTest() {
        withStaticTestingContext {
            super.invokeTest()
        }
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

            #expectWasCalled(SpyTestCase.staticFoo)
                .occurring(times: 2)
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

    func testStubbingStaticFunction() {
        StubProvider.setStub(for: StubProvider.staticFoo, withSignature: "staticFoo()", returning: 63)

        XCTAssertEqual(StubProvider.staticFoo(), 63)
    }

    func testStubbingStaticFunction2() {
        StubProvider.setStub(for: StubProvider.staticFoo, withSignature: "staticFoo()", returning: 36)

        XCTAssertEqual(StubProvider.staticFoo(), 36)
    }

}

private struct StubProvider: StubProviding {

    let stubRegistry = StubRegistry()

    static func staticFoo() -> Int {
        stubOutput()
    }

}

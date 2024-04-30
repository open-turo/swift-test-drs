@testable import TestDRS
import XCTest

final class SpyAssertionsTests: SpyTestCase {

    // MARK: - assertCallCount

    func testAssertCallCount_WithNoCalls() {
        assertCallCount(to: "foo()", equals: 0)

        XCTExpectFailure()
        assertCallCount(to: "foo()", equals: 1)
    }

    func testAssertCallCount_WithMultipleCalls() {
        foo()
        foo()
        foo()

        assertCallCount(to: "foo()", equals: 3)

        XCTExpectFailure()
        assertCallCount(to: "foo()", equals: 1)
    }

    func testAssertCallCountWithInputType_WithNoCalls() {
        assertCallCount(to: "zab(paramOne:)", withInputType: Bool.self, equals: 0)

        XCTExpectFailure()
        assertCallCount(to: "zab(paramOne:)", withInputType: Bool.self, equals: 1)
    }

    func testAssertCallCountWithInputType_WithMultipleCalls() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        assertCallCount(to: "zab(paramOne:)", withInputType: Bool.self, equals: 1)
        assertCallCount(to: "zab(paramOne:)", withInputType: String.self, equals: 2)
        assertCallCount(to: "zab(paramOne:)", withInputType: Int.self, equals: 3)

        XCTExpectFailure()
        assertCallCount(to: "zab(paramOne:)", withInputType: Bool.self, equals: 4)
        XCTExpectFailure()
        assertCallCount(to: "zab(paramOne:)", withInputType: String.self, equals: 4)
        XCTExpectFailure()
        assertCallCount(to: "zab(paramOne:)", withInputType: Int.self, equals: 4)
    }

    // MARK: - assertWasCalled

    func testAssertWasCalled_WithoutCalling() {
        XCTExpectFailure()
        assertWasCalled("foo()")
    }

    func testAssertWasCalled_WithNoParameters() {
        foo()
        assertWasCalled("foo()")
    }

    func testAssertWasCalled_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        assertWasCalled("zab(paramOne:)", with: true)
        assertWasCalled("zab(paramOne:)", with: "Hello")
        assertWasCalled("zab(paramOne:)", with: "World")
        assertWasCalled("zab(paramOne:)", with: 1)
        assertWasCalled("zab(paramOne:)", with: 2)
        assertWasCalled("zab(paramOne:)", with: 3)

        XCTExpectFailure()
        assertWasCalled("zab(paramOne:)", with: false)
        XCTExpectFailure()
        assertWasCalled("zab(paramOne:)", with: "Goodbye")
        XCTExpectFailure()
        assertWasCalled("zab(paramOne:)", with: 4)
    }

    func testAssertWasCalled_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: false, paramTwo: nil, paramThree: nil)

        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: true, 1, "Hello")
        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: false, Int?.none, String?.none)

        XCTExpectFailure()
        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: true, 2, "Hello")
        XCTExpectFailure()
        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: true, Int?.none, String?.none)
    }

    // MARK: - assertWasCalledExactlyOnce

    func testAssertWasCalledExactlyOnce_WithoutCalling() {
        XCTExpectFailure()
        assertWasCalledExactlyOnce("foo()")
    }

    func testAssertWasCalledExactlyOnce_WithNoParameters() {
        foo()
        assertWasCalledExactlyOnce("foo()")

        foo()

        XCTExpectFailure()
        assertWasCalledExactlyOnce("foo()")
    }

    func testAssertWasCalledExactlyOnce_WithSingleParameter() {
        bar(paramOne: true)

        assertWasCalledExactlyOnce("bar(paramOne:)", with: true)

        XCTExpectFailure()
        assertWasCalledExactlyOnce("bar(paramOne:)", with: false)
    }

    func testAssertWasCalledExactlyOnce_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        assertWasCalledExactlyOnce("rab(paramOne:paramTwo:paramThree:)", with: true, 1, "Hello")

        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        XCTExpectFailure()
        assertWasCalledExactlyOnce("rab(paramOne:paramTwo:paramThree:)", with: true, 1, "Hello")
    }

    func testAssertWasCalledExactlyOnce_WithMultipleCalls_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello World")

        XCTExpectFailure()
        assertWasCalledExactlyOnce("zab(paramOne:)")

        XCTExpectFailure()
        assertWasCalledExactlyOnce("zab(paramOne:)", with: true)
    }

    // MARK: - assertWasCalledFirst

    func testAssertWasCalledFirst_WithoutCalling() {
        XCTExpectFailure()
        assertWasCalledFirst("foo()")
    }

    func testAssertWasCalledFirst_WithNoParameters() {
        foo()
        bar(paramOne: true)

        assertWasCalledFirst("foo()")

        XCTExpectFailure()
        assertWasCalledFirst("bar(paramOne:)")
    }

    func testAssertWasCalledFirst_WithSingleParameter() {
        bar(paramOne: true)
        foo()

        assertWasCalledFirst("bar(paramOne:)", with: true)

        XCTExpectFailure()
        assertWasCalledFirst("bar(paramOne:)", with: false)
    }

    func testAssertWasCalledFirst_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 2, paramThree: "World")
        oof(paramOne: false, paramTwo: 3)

        assertWasCalledFirst("rab(paramOne:paramTwo:paramThree:)", with: true, 1, "Hello")

        XCTExpectFailure()
        assertWasCalledFirst("rab(paramOne:paramTwo:paramThree:)", with: true, 2, "World")
        XCTExpectFailure()
        assertWasCalledFirst("oof(paramOne:paramTwo:)", with: false, 3)
    }

    func testAssertWasCalledFirst_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")

        assertWasCalledFirst("zab(paramOne:)", with: true)

        XCTExpectFailure()
        assertWasCalledFirst("zab(paramOne:)", with: "Hello")
    }

    // MARK: - assertWasCalledLast

    func testAssertWasCalledLast_WithoutCalling() {
        XCTExpectFailure()
        assertWasCalledLast("foo()")
    }

    func testAssertWasCalledLast_WithNoParameters() throws {
        bar(paramOne: true)
        foo()

        let callToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").first)

        let callToFoo = assertWasCalledLast("foo()")
        assertWasCalledLast("foo()", immediatelyAfter: callToBar)

        XCTExpectFailure()
        assertWasCalledLast("bar(paramOne:)")
        XCTExpectFailure()
        assertWasCalledLast("foo()", immediatelyAfter: callToFoo)
    }

    func testAssertWasCalledLast_WithSingleParameter() throws {
        foo()
        bar(paramOne: true)

        let callToFoo = try XCTUnwrap(calls(to: "foo()").first)

        let callToBar = assertWasCalledLast("bar(paramOne:)", with: true)
        assertWasCalledLast("bar(paramOne:)", with: true, immediatelyAfter: callToFoo)

        XCTExpectFailure()
        assertWasCalledLast("bar(paramOne:)", with: false)
        XCTExpectFailure()
        assertWasCalledLast("bar(paramOne:)", with: true, immediatelyAfter: callToBar)
    }

    func testAssertWasCalledLast_WithMultipleParameters() throws {
        oof(paramOne: false, paramTwo: 1)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 3, paramThree: "World")

        let firstCallToRab = try XCTUnwrap(calls(to: "rab(paramOne:paramTwo:paramThree:)").first)

        let lastCallToRab = assertWasCalledLast("rab(paramOne:paramTwo:paramThree:)", with: true, 3, "World")
        assertWasCalledLast("rab(paramOne:paramTwo:paramThree:)", with: true, 3, "World", immediatelyAfter: firstCallToRab)

        XCTExpectFailure()
        assertWasCalledLast("rab(paramOne:paramTwo:paramThree:)", with: true, 2, "Hello")
        XCTExpectFailure()
        assertWasCalledLast("oof(paramOne:paramTwo:)", with: false, 1)
        XCTExpectFailure()
        assertWasCalledLast("rab(paramOne:paramTwo:paramThree:)", with: true, 3, "World", immediatelyAfter: lastCallToRab)
    }

    func testAssertWasCalledLast_WithDifferentParameterTypes() throws {
        zab(paramOne: true)
        zab(paramOne: "Hello")

        let firstCallToZab = try XCTUnwrap(calls(to: "zab(paramOne:)").first)

        let lastCallToZab = assertWasCalledLast("zab(paramOne:)", with: "Hello")
        assertWasCalledLast("zab(paramOne:)", with: "Hello", immediatelyAfter: firstCallToZab)

        XCTExpectFailure()
        assertWasCalledLast("zab(paramOne:)", with: true)

        XCTExpectFailure()
        assertWasCalledLast("zab(paramOne:)", with: "Hello", immediatelyAfter: lastCallToZab)
    }

    // MARK: - assertWasCalled after previousCall

    func testAssertWasCalledAfter_WithoutCallingAnything() {
        XCTExpectFailure()
        assertWasCalled("foo()", after: ConcreteFunctionCall(signature: "", input: Void(), output: Void(), time: Date()))
    }

    func testAssertWasCalledAfter_WithNoParameters() throws {
        bar(paramOne: true)
        foo()
        bar(paramOne: true)

        let firstCallToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").first)
        let lastCallToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").last)

        assertWasCalled("foo()", after: firstCallToBar)

        XCTExpectFailure()
        assertWasCalled("foo()", after: lastCallToBar)
    }

    func testAssertWasCalledAfter_WithSingleParameter() throws {
        foo()
        bar(paramOne: true)
        foo()

        let firstCallToFoo = try XCTUnwrap(calls(to: "foo()").first)
        let lastCallToFoo = try XCTUnwrap(calls(to: "foo()").last)

        assertWasCalled("bar(paramOne:)", after: firstCallToFoo)

        XCTExpectFailure()
        assertWasCalled("bar(paramOne:)", with: false, after: firstCallToFoo)
        XCTExpectFailure()
        assertWasCalled("bar(paramOne:)", after: lastCallToFoo)
    }

    func testAssertWasCalledAfter_WithMultipleParameters() throws {
        oof(paramOne: false, paramTwo: 1)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")
        oof(paramOne: false, paramTwo: 3)

        let firstCallToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").first)
        let lastCallToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").last)

        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: true, 2, "Hello", after: firstCallToOof)

        XCTExpectFailure()
        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: false, 2, "Hello", after: lastCallToOof)
        XCTExpectFailure()
        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: true, 3, "Hello", after: lastCallToOof)
    }

    func testAssertWasCalledAfter_WithDifferentParameterTypes() throws {
        baz(paramOne: false)
        zab(paramOne: true)
        baz(paramOne: true)
        zab(paramOne: "Hello")

        let firstCallToBaz = try XCTUnwrap(calls(to: "baz(paramOne:)").first)
        let lastCallToBaz = try XCTUnwrap(calls(to: "baz(paramOne:)").last)

        assertWasCalled("zab(paramOne:)", with: true, after: firstCallToBaz)
        assertWasCalled("zab(paramOne:)", with: "Hello", after: firstCallToBaz)
        assertWasCalled("zab(paramOne:)", with: "Hello", after: lastCallToBaz)

        XCTExpectFailure()
        assertWasCalled("zab(paramOne:)", with: false, after: firstCallToBaz)
        XCTExpectFailure()
        assertWasCalled("zab(paramOne:)", with: true, after: lastCallToBaz)
    }

    // MARK: - assertWasCalled immediatelyAfter previousCall

    func testAssertWasCalledImmediatelyAfter_WithoutCallingAnything() {
        XCTExpectFailure()
        assertWasCalled("foo()", immediatelyAfter: ConcreteFunctionCall(signature: "", input: Void(), output: Void(), time: Date()))
    }

    func testAssertWasCalledImmediatelyAfter_WithNoParameters() throws {
        bar(paramOne: true)
        bar(paramOne: true)
        foo()

        let firstCallToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").first)
        let secondCallToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").last)

        assertWasCalled("foo()", immediatelyAfter: secondCallToBar)

        XCTExpectFailure()
        assertWasCalled("foo()", immediatelyAfter: firstCallToBar)
    }

    func testAssertWasCalledImmediatelyAfter_WithSingleParameter() throws {
        foo()
        foo()
        bar(paramOne: true)

        let firstCallToFoo = try XCTUnwrap(calls(to: "foo()").first)
        let lastCallToFoo = try XCTUnwrap(calls(to: "foo()").last)

        assertWasCalled("bar(paramOne:)", immediatelyAfter: lastCallToFoo)

        XCTExpectFailure()
        assertWasCalled("bar(paramOne:)", with: false, after: lastCallToFoo)
        XCTExpectFailure()
        assertWasCalled("bar(paramOne:)", immediatelyAfter: firstCallToFoo)
    }

    func testAssertWasCalledImmediatelyAfter_WithMultipleParameters() throws {
        oof(paramOne: false, paramTwo: 1)
        oof(paramOne: false, paramTwo: 3)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")

        let firstCallToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").first)
        let lastCallToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").last)

        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: true, 2, "Hello", immediatelyAfter: lastCallToOof)

        XCTExpectFailure()
        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: false, 2, "Hello", immediatelyAfter: lastCallToOof)
        XCTExpectFailure()
        assertWasCalled("rab(paramOne:paramTwo:paramThree:)", with: true, 3, "Hello", immediatelyAfter: firstCallToOof)
    }

    func testAssertWasCalledImmediatelyAfter_WithDifferentParameterTypes() throws {
        baz(paramOne: false)
        zab(paramOne: true)
        baz(paramOne: true)
        zab(paramOne: "Hello")

        let firstCallToBaz = try XCTUnwrap(calls(to: "baz(paramOne:)").first)
        let lastCallToBaz = try XCTUnwrap(calls(to: "baz(paramOne:)").last)

        assertWasCalled("zab(paramOne:)", with: true, immediatelyAfter: firstCallToBaz)
        assertWasCalled("zab(paramOne:)", with: "Hello", immediatelyAfter: lastCallToBaz)

        XCTExpectFailure()
        assertWasCalled("zab(paramOne:)", with: false, immediatelyAfter: firstCallToBaz)
        XCTExpectFailure()
        assertWasCalled("zab(paramOne:)", with: true, immediatelyAfter: lastCallToBaz)
    }
}

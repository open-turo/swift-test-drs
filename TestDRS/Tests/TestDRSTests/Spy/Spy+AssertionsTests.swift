@testable import TestDRS
import XCTest

final class SpyAssertionsTests: SpyTestCase {

    // MARK: - assertCallCount

    func testAssertCallCount_WithNoCalls() {
        assertCallCount(to: foo, withSignature: "foo()", equals: 0)

        XCTExpectFailure {
            assertCallCount(to: foo, withSignature: "foo()", equals: 1)
        }
    }

    func testAssertCallCount_WithMultipleCalls() {
        foo()
        foo()
        foo()

        assertCallCount(to: foo, withSignature: "foo()", equals: 3)

        XCTExpectFailure {
            assertCallCount(to: foo, withSignature: "foo()", equals: 1)
        }
    }

    func testAssertCallCountWithInputType_WithNoCalls() {
        assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, equals: 0)

        XCTExpectFailure {
            assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, equals: 1)
        }
    }

    func testAssertCallCountWithInputType_WithMultipleCalls() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, equals: 1)
        assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: String.self, equals: 2)
        assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Int.self, equals: 3)

        XCTExpectFailure {
            assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, equals: 4)
        }
        XCTExpectFailure {
            assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: String.self, equals: 4)
        }
        XCTExpectFailure {
            assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Int.self, equals: 4)
        }
    }

    // MARK: - assertWasCalled

    func testAssertWasCalled_WithoutCalling() {
        XCTExpectFailure()
        assertWasCalled(foo, withSignature: "foo()")
    }

    func testAssertWasCalled_WithNoParameters() {
        foo()
        assertWasCalled(foo, withSignature: "foo()")
    }

    func testAssertWasCalled_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "World")
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 1)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 2)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 3)

        XCTExpectFailure {
            _ = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: false)
        }
        XCTExpectFailure {
            _ = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Goodbye")
        }
        XCTExpectFailure {
            _ = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 4)
        }
    }

    func testAssertWasCalled_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: false, paramTwo: nil, paramThree: nil)

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")
        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: false, Int?.none, String?.none)

        XCTExpectFailure {
            _ = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
        }
        XCTExpectFailure {
            _ = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, Int?.none, String?.none)
        }
    }

    func testAssertWasCalled_WithPredicate() {
        rab(paramOne: false, paramTwo: nil, paramThree: nil)
        rab(paramOne: true, paramTwo: 1, paramThree: nil)

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)") { call in
            guard let paramTwo = call.input.1 else { return false }
            return paramTwo < 5
        }
        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)") { call in
            call.input.1 == nil && call.input.2 == nil
        }

        XCTExpectFailure {
            _ = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)") { call in
                guard let paramTwo = call.input.1 else { return false }
                return paramTwo > 5
            }
        }
        XCTExpectFailure {
            _ = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)") { call in
                guard let paramThree = call.input.2 else { return false }
                return paramThree == "Hello World"
            }
        }
    }

    // MARK: - assertWasCalledExactlyOnce

    func testAssertWasCalledExactlyOnce_WithoutCalling() {
        XCTExpectFailure {
            _ = assertWasCalledExactlyOnce(foo, withSignature: "foo()")
        }
    }

    func testAssertWasCalledExactlyOnce_WithNoParameters() {
        foo()
        assertWasCalledExactlyOnce(foo, withSignature: "foo()")

        foo()

        XCTExpectFailure {
            _ = assertWasCalledExactlyOnce(foo, withSignature: "foo()")
        }
    }

    func testAssertWasCalledExactlyOnce_WithSingleParameter() {
        bar(paramOne: true)

        assertWasCalledExactlyOnce(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true)

        XCTExpectFailure {
            _ = assertWasCalledExactlyOnce(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: false)
        }
    }

    func testAssertWasCalledExactlyOnce_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        assertWasCalledExactlyOnce(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")

        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        XCTExpectFailure {
            _ = assertWasCalledExactlyOnce(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")
        }
    }

    func testAssertWasCalledExactlyOnce_WithMultipleCalls_WithDifferentParameterTypes() {
//        zab(paramOne: true)
        zab(paramOne: "Hello World")

        XCTExpectFailure {
            _ = assertWasCalledExactlyOnce(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self)
        }

        XCTExpectFailure {
            _ = assertWasCalledExactlyOnce(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)
        }

        let call = assertWasCalledExactlyOnce(zab(paramOne:), withSignature: "zab(paramOne:)", returning: String.self)
        XCTAssertEqual(call?.output, "Hello World")
    }

    // MARK: - assertWasCalledFirst

    func testAssertWasCalledFirst_WithoutCalling() {
        XCTExpectFailure {
            _ = assertWasCalledFirst(foo, withSignature: "foo()")
        }
    }

    func testAssertWasCalledFirst_WithNoParameters() {
        foo()
        bar(paramOne: true)

        assertWasCalledFirst(foo, withSignature: "foo()")

        XCTExpectFailure {
            _ = assertWasCalledFirst(bar(paramOne:), withSignature: "bar(paramOne:)")
        }
    }

    func testAssertWasCalledFirst_WithSingleParameter() {
        bar(paramOne: true)
        foo()

        assertWasCalledFirst(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true)

        XCTExpectFailure {
            _ = assertWasCalledFirst(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: false)
        }
    }

    func testAssertWasCalledFirst_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 2, paramThree: "World")
        oof(paramOne: false, paramTwo: 3)

        assertWasCalledFirst(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")

        XCTExpectFailure {
            _ = assertWasCalledFirst(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "World")
        }
        XCTExpectFailure {
            _ = assertWasCalledFirst(oof(paramOne:paramTwo:), withSignature: "oof(paramOne:paramTwo:)", expectedInput: false, 3)
        }
    }

    func testAssertWasCalledFirst_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")

        assertWasCalledFirst(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)

        XCTExpectFailure {
            _ = assertWasCalledFirst(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
        }
    }

    // MARK: - assertWasCalledLast

    func testAssertWasCalledLast_WithoutCalling() {
        XCTExpectFailure {
            _ = assertWasCalledLast(foo, withSignature: "foo()")
        }
    }

    func testAssertWasCalledLast_WithNoParameters() throws {
        bar(paramOne: true)
        foo()

        let callToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").first)

        let callToFoo = assertWasCalledLast(foo, withSignature: "foo()")
        assertWasCalledLast(foo, withSignature: "foo()", immediatelyAfter: callToBar)

        XCTExpectFailure {
            _ = assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)")
        }
        XCTExpectFailure {
            _ = assertWasCalledLast(foo, withSignature: "foo()", immediatelyAfter: callToFoo)
        }
    }

    func testAssertWasCalledLast_WithSingleParameter() throws {
        foo()
        bar(paramOne: true)

        let callToFoo = try XCTUnwrap(calls(to: "foo()").first)

        let callToBar = assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true)
        assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true, immediatelyAfter: callToFoo)

        XCTExpectFailure {
            _ = assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: false)
        }
        XCTExpectFailure {
            _ = assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true, immediatelyAfter: callToBar)
        }
    }

    func testAssertWasCalledLast_WithMultipleParameters() throws {
        oof(paramOne: false, paramTwo: 1)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 3, paramThree: "World")

        let firstCallToRab = try XCTUnwrap(calls(to: "rab(paramOne:paramTwo:paramThree:)").first)

        let lastCallToRab = assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "World")
        assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "World", immediatelyAfter: firstCallToRab)

        XCTExpectFailure {
            _ = assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
        }
        XCTExpectFailure {
            _ = assertWasCalledLast(oof(paramOne:paramTwo:), withSignature: "oof(paramOne:paramTwo:)", expectedInput: false, 1)
        }
        XCTExpectFailure {
            _ = assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "World", immediatelyAfter: lastCallToRab)
        }
    }

    func testAssertWasCalledLast_WithDifferentParameterTypes() throws {
        zab(paramOne: true)
        zab(paramOne: "Hello")

        let firstCallToZab = try XCTUnwrap(calls(to: "zab(paramOne:)").first)

        let lastCallToZab = assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
        assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello", immediatelyAfter: firstCallToZab)

        XCTExpectFailure {
            _ = assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)
        }

        XCTExpectFailure {
            _ = assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello", immediatelyAfter: lastCallToZab)
        }
    }

    // MARK: - assertWasCalled after previousCall

    func testAssertWasCalledAfter_WithoutCallingAnything() {
        XCTExpectFailure {
            _ = assertWasCalled(foo, withSignature: "foo()", after: ConcreteFunctionCall(signature: "", input: Void(), output: Void(), time: Date()))
        }
    }

    func testAssertWasCalledAfter_WithNoParameters() throws {
        bar(paramOne: true)
        foo()
        bar(paramOne: true)

        let firstCallToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").first)
        let lastCallToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").last)

        assertWasCalled(foo, withSignature: "foo()", after: firstCallToBar)

        XCTExpectFailure {
            _ = assertWasCalled(foo, withSignature: "foo()", after: lastCallToBar)
        }
    }

    func testAssertWasCalledAfter_WithSingleParameter() throws {
        foo()
        bar(paramOne: true)
        foo()

        let firstCallToFoo = try XCTUnwrap(calls(to: "foo()").first)
        let lastCallToFoo = try XCTUnwrap(calls(to: "foo()").last)

        assertWasCalled(bar(paramOne:), withSignature: "bar(paramOne:)", after: firstCallToFoo)

        XCTExpectFailure {
            _ = assertWasCalled(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: false, after: firstCallToFoo)
        }
        XCTExpectFailure {
            _ = assertWasCalled(bar(paramOne:), withSignature: "bar(paramOne:)", after: lastCallToFoo)
        }
    }

    func testAssertWasCalledAfter_WithMultipleParameters() throws {
        oof(paramOne: false, paramTwo: 1)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")
        oof(paramOne: false, paramTwo: 3)

        let firstCallToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").first)
        let lastCallToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").last)

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello", after: firstCallToOof)

        XCTExpectFailure {
            _ = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: false, 2, "Hello", after: lastCallToOof)
        }
        XCTExpectFailure {
            _ = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "Hello", after: lastCallToOof)
        }
    }

    func testAssertWasCalledAfter_WithDifferentParameterTypes() throws {
        baz(paramOne: false)
        zab(paramOne: true)
        baz(paramOne: true)
        zab(paramOne: "Hello")

        let firstCallToBaz = try XCTUnwrap(calls(to: "baz(paramOne:)").first)
        let lastCallToBaz = try XCTUnwrap(calls(to: "baz(paramOne:)").last)

        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true, after: firstCallToBaz)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello", after: firstCallToBaz)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello", after: lastCallToBaz)

        XCTExpectFailure {
            _ = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: false, after: firstCallToBaz)
        }
        XCTExpectFailure {
            _ = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true, after: lastCallToBaz)
        }
    }

    // MARK: - assertWasCalled immediatelyAfter previousCall

    func testAssertWasCalledImmediatelyAfter_WithoutCallingAnything() {
        XCTExpectFailure {
            _ = assertWasCalled(foo, withSignature: "foo()", immediatelyAfter: ConcreteFunctionCall(signature: "", input: Void(), output: Void(), time: Date()))
        }
    }

    func testAssertWasCalledImmediatelyAfter_WithNoParameters() throws {
        bar(paramOne: true)
        bar(paramOne: true)
        foo()

        let firstCallToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").first)
        let secondCallToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").last)

        assertWasCalled(foo, withSignature: "foo()", immediatelyAfter: secondCallToBar)

        XCTExpectFailure {
            _ = assertWasCalled(foo, withSignature: "foo()", immediatelyAfter: firstCallToBar)
        }
    }

    func testAssertWasCalledImmediatelyAfter_WithSingleParameter() throws {
        foo()
        foo()
        bar(paramOne: true)

        let firstCallToFoo = try XCTUnwrap(calls(to: "foo()").first)
        let lastCallToFoo = try XCTUnwrap(calls(to: "foo()").last)

        assertWasCalled(bar(paramOne:), withSignature: "bar(paramOne:)", immediatelyAfter: lastCallToFoo)

        XCTExpectFailure {
            _ = assertWasCalled(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: false, after: lastCallToFoo)
        }
        XCTExpectFailure {
            _ = assertWasCalled(bar(paramOne:), withSignature: "bar(paramOne:)", immediatelyAfter: firstCallToFoo)
        }
    }

    func testAssertWasCalledImmediatelyAfter_WithMultipleParameters() throws {
        oof(paramOne: false, paramTwo: 1)
        oof(paramOne: false, paramTwo: 3)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")

        let firstCallToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").first)
        let lastCallToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").last)

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello", immediatelyAfter: lastCallToOof)

        XCTExpectFailure {
            _ = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: false, 2, "Hello", immediatelyAfter: lastCallToOof)
        }
        XCTExpectFailure {
            _ = assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "Hello", immediatelyAfter: firstCallToOof)
        }
    }

    func testAssertWasCalledImmediatelyAfter_WithDifferentParameterTypes() throws {
        baz(paramOne: false)
        zab(paramOne: true)
        baz(paramOne: true)
        zab(paramOne: "Hello")

        let firstCallToBaz = try XCTUnwrap(calls(to: "baz(paramOne:)").first)
        let lastCallToBaz = try XCTUnwrap(calls(to: "baz(paramOne:)").last)

        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true, immediatelyAfter: firstCallToBaz)
        assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello", immediatelyAfter: lastCallToBaz)

        XCTExpectFailure {
            _ = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: false, immediatelyAfter: firstCallToBaz)
        }
        XCTExpectFailure {
            _ = assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true, immediatelyAfter: lastCallToBaz)
        }
    }

}

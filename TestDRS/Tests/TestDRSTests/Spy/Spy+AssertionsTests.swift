@testable import TestDRS
import XCTest

final class SpyAssertionsTests: SpyTestCase {

    private let file = #fileID.components(separatedBy: "/").last!
    private var line = 0

    // MARK: - assertCallCount

    func testAssertCallCount_WithNoCalls() {
        assertCallCount(to: foo, withSignature: "foo()", equals: 0)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertCallCount(to: foo, withSignature: "foo()", equals: 1)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called 1 times, but 0 calls were recorded with input type () and output type ()
                """
            }
        )
    }

    func testAssertCallCount_WithMultipleCalls() {
        foo()
        foo()
        foo()

        assertCallCount(to: foo, withSignature: "foo()", equals: 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertCallCount(to: foo, withSignature: "foo()", equals: 1)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called 1 times, but 3 calls were recorded with input type () and output type ():

                +()
                +()
                +()
                """
            }
        )
    }

    func testAssertCallCount_WithParameter_WithNoCalls() {
        assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, equals: 0)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, equals: 1)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected zab(paramOne:) to be called 1 times, but 0 calls were recorded with input type Bool and output type Bool
                """
            }
        )
    }

    func testAssertCallCount_WithGenericParameter_WithMultipleCalls() {
        zab(paramOne: true)
        zab(paramOne: "Hello")
        zab(paramOne: "World")
        zab(paramOne: 1)
        zab(paramOne: 2)
        zab(paramOne: 3)

        assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, equals: 1)
        assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: String.self, equals: 2)
        assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Int.self, equals: 3)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self, equals: 4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected zab(paramOne:) to be called 4 times, but 1 calls were recorded with input type Bool and output type Bool:

                +true
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: String.self, equals: 4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected zab(paramOne:) to be called 4 times, but 2 calls were recorded with input type String and output type String:

                +Hello
                +World
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertCallCount(to: zab(paramOne:), withSignature: "zab(paramOne:)", taking: Int.self, equals: 4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected zab(paramOne:) to be called 4 times, but 3 calls were recorded with input type Int and output type Int:

                +1
                +2
                +3
                """
            }
        )
    }

    // MARK: - assertWasCalled

    func testAssertWasCalled_WithoutCalling() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to foo() were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(foo, withSignature: "foo()", taking: Void.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to foo() were recorded
                """
            }
        )
    }

    func testAssertWasCalled_WithNoParameters() {
        foo()
        assertWasCalled(foo, withSignature: "foo()", taking: Void.self)
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

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Double.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to zab(paramOne:) with input type Double and output type Double were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 1.0)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to zab(paramOne:) with input type Double and output type Double were recorded
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: false)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): zab(paramOne:) was not called with expected input (-), but was called with other input (+):

                -false
                +true
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Goodbye")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): zab(paramOne:) was not called with expected input (-), but was called with other input (+):

                -Goodbye
                +Hello
                +World
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: 4)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): zab(paramOne:) was not called with expected input (-), but was called with other input (+):

                -4
                +1
                +2
                +3
                """
            }
        )
    }

    func testAssertWasCalled_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: false, paramTwo: nil, paramThree: nil)

        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")
        assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: false, Int?.none, String?.none)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): rab(paramOne:paramTwo:paramThree:) was not called with expected input (-), but was called with other input (+):

                -(true, Optional(2), Optional("Hello"))
                +(true, Optional(1), Optional("Hello"))
                +(false, nil, nil)
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, Int?.none, String?.none)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): rab(paramOne:paramTwo:paramThree:) was not called with expected input (-), but was called with other input (+):

                -(true, nil, nil)
                +(true, Optional(1), Optional("Hello"))
                +(false, nil, nil)
                """
            }
        )
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

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)") { call in
                    guard let paramTwo = call.input.1 else { return false }
                    return paramTwo > 5
                }
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to rab(paramOne:paramTwo:paramThree:) were recorded where the predicate returned true
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalled(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)") { call in
                    guard let paramThree = call.input.2 else { return false }
                    return paramThree == "Hello World"
                }
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to rab(paramOne:paramTwo:paramThree:) were recorded where the predicate returned true
                """
            }
        )
    }

    // MARK: - assertWasCalledExactlyOnce

    func testAssertWasCalledExactlyOnce_WithoutCalling() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledExactlyOnce(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called exactly once, but 0 calls were recorded
                """
            }
        )
    }

    func testAssertWasCalledExactlyOnce_WithNoParameters() {
        foo()

        assertWasCalledExactlyOnce(foo, withSignature: "foo()")

        foo()

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledExactlyOnce(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected foo() to be called exactly once, but 2 calls were recorded
                """
            }
        )
    }

    func testAssertWasCalledExactlyOnce_WithSingleParameter() {
        bar(paramOne: true)

        assertWasCalledExactlyOnce(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledExactlyOnce(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: false)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): bar(paramOne:) was called exactly once, but with different input (+) than expected (-):

                -false
                +true
                """
            }
        )

        bar(paramOne: true)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledExactlyOnce(bar(paramOne:), withSignature: "bar(paramOne:)")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected bar(paramOne:) to be called exactly once, but 2 calls were recorded
                """
            }
        )
    }

    func testAssertWasCalledExactlyOnce_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        assertWasCalledExactlyOnce(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")

        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledExactlyOnce(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected rab(paramOne:paramTwo:paramThree:) to be called exactly once, but 2 calls were recorded
                """
            }
        )
    }

    func testAssertWasCalledExactlyOnce_WithMultipleCalls_WithDifferentParameterTypes() {
        zab(paramOne: "Hello World")

        let call = assertWasCalledExactlyOnce(zab(paramOne:), withSignature: "zab(paramOne:)", returning: String.self)
        XCTAssertEqual(call?.output, "Hello World")

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledExactlyOnce(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Bool.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): zab(paramOne:) was called exactly once, but not with input type Bool and output type Bool
                """
            }
        )

        zab(paramOne: true)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledExactlyOnce(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected zab(paramOne:) to be called exactly once, but 2 calls were recorded
                """
            }
        )
    }

    func testAssertWasCalledExactlyOnce_WithDifferentOutputTypes() {
        let _: StructA = zoo()

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledExactlyOnce(zoo, withSignature: "zoo()", returning: StructB.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): zoo() was called exactly once with the expected input, but not with the output type StructB
                """
            }
        )
    }

    // MARK: - assertWasCalledFirst

    func testAssertWasCalledFirst_WithoutCalling() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledFirst(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to foo() were recorded
                """
            }
        )
    }

    func testAssertWasCalledFirst_WithNoParameters() {
        foo()
        bar(paramOne: true)

        assertWasCalledFirst(foo, withSignature: "foo()", taking: Void.self)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledFirst(bar(paramOne:), withSignature: "bar(paramOne:)")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected bar(paramOne:) to be called first but foo() was called first
                """
            }
        )
    }

    func testAssertWasCalledFirst_WithSingleParameter() {
        bar(paramOne: true)
        foo()

        assertWasCalledFirst(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledFirst(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: false)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): First call was to bar(paramOne:), but with different input (+) than expected (-):

                -false
                +true
                """
            }
        )
    }

    func testAssertWasCalledFirst_WithMultipleParameters() {
        rab(paramOne: true, paramTwo: 1, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 2, paramThree: "World")
        oof(paramOne: false, paramTwo: 3)

        assertWasCalledFirst(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 1, "Hello")

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledFirst(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "World")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): First call was to rab(paramOne:paramTwo:paramThree:), but with different input (+) than expected (-):

                -(true, Optional(2), Optional("World"))
                +(true, Optional(1), Optional("Hello"))
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledFirst(oof(paramOne:paramTwo:), withSignature: "oof(paramOne:paramTwo:)", expectedInput: false, 3)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected oof(paramOne:paramTwo:) to be called first but rab(paramOne:paramTwo:paramThree:) was called first
                """
            }
        )
    }

    func testAssertWasCalledFirst_WithDifferentParameterTypes() {
        zab(paramOne: true)
        zab(paramOne: "Hello")

        assertWasCalledFirst(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: true)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledFirst(zab(paramOne:), withSignature: "zab(paramOne:)", taking: String.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): First call was to zab(paramOne:), but not with input type String and output type String
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledFirst(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): First call was to zab(paramOne:), but with different input (+) than expected (-):

                -Hello
                +true
                """
            }
        )
    }

    func testAssertWasCalledFirst_WithDifferentOutputTypes() {
        let _: StructA = zoo()

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledFirst(zoo, withSignature: "zoo()", returning: StructB.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): First call was to zoo() with the expected input, but not with the output type StructB
                """
            }
        )
    }

    // MARK: - assertWasCalledLast

    func testAssertWasCalledLast_WithoutCalling() {
        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(foo, withSignature: "foo()")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls to foo() were recorded
                """
            }
        )
    }

    func testAssertWasCalledLast_WithNoParameters() throws {
        bar(paramOne: true)
        foo()

        let callToBar = try XCTUnwrap(calls(to: "bar(paramOne:)").first)

        let callToFoo = assertWasCalledLast(foo, withSignature: "foo()")
        assertWasCalledLast(foo, withSignature: "foo()", immediatelyAfter: callToBar)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Expected bar(paramOne:) to be called last but foo() was called last
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(foo, withSignature: "foo()", taking: Void.self, immediatelyAfter: callToFoo)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls were recorded after foo()
                """
            }
        )
    }

    func testAssertWasCalledLast_WithSingleParameter() throws {
        foo()
        bar(paramOne: true)

        let callToFoo = try XCTUnwrap(calls(to: "foo()").first)

        let callToBar = assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true)
        assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", immediatelyAfter: callToFoo)
        assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true, immediatelyAfter: callToFoo)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: false)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Last call was to bar(paramOne:), but with different input (+) than expected (-):

                -false
                +true
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(bar(paramOne:), withSignature: "bar(paramOne:)", expectedInput: true, immediatelyAfter: callToBar)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls were recorded after bar(paramOne:)
                """
            }
        )
    }

    func testAssertWasCalledLast_WithMultipleParameters() throws {
        oof(paramOne: false, paramTwo: 1)
        rab(paramOne: true, paramTwo: 2, paramThree: "Hello")
        rab(paramOne: true, paramTwo: 3, paramThree: "World")

        let callToOof = try XCTUnwrap(calls(to: "oof(paramOne:paramTwo:)").first)
        let firstCallToRab = try XCTUnwrap(calls(to: "rab(paramOne:paramTwo:paramThree:)").first)

        let lastCallToRab = assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "World")
        assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "World", immediatelyAfter: firstCallToRab)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 2, "Hello")
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Last call was to rab(paramOne:paramTwo:paramThree:), but with different input (+) than expected (-):

                -(true, Optional(2), Optional("Hello"))
                +(true, Optional(3), Optional("World"))
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", immediatelyAfter: callToOof)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Last call was not immediately after previous call to oof(paramOne:paramTwo:)
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(rab(paramOne:paramTwo:paramThree:), withSignature: "rab(paramOne:paramTwo:paramThree:)", expectedInput: true, 3, "World", immediatelyAfter: callToOof)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Last call was not immediately after previous call to oof(paramOne:paramTwo:)
                """
            }
        )
    }

    func testAssertWasCalledLast_WithDifferentParameterTypes() throws {
        zab(paramOne: true)
        zab(paramOne: "Hello")

        let firstCallToZab = try XCTUnwrap(calls(to: "zab(paramOne:)").first)

        let lastCallToZab = assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", returning: String.self)
        assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello")
        assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello", immediatelyAfter: firstCallToZab)

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", taking: Double.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Last call was to zab(paramOne:), but not with input type Double and output type Double
                """
            }
        )

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(zab(paramOne:), withSignature: "zab(paramOne:)", expectedInput: "Hello", immediatelyAfter: lastCallToZab)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): No calls were recorded after zab(paramOne:)
                """
            }
        )
    }

    func testAssertWasCalledLast_WithDifferentOutputTypes() {
        let _: StructA = zoo()

        XCTExpectFailure(
            failingBlock: {
                line = #line + 1
                assertWasCalledLast(zoo, withSignature: "zoo()", returning: StructB.self)
            },
            issueMatcher: { issue in
                issue.description == """
                Assertion Failure at \(self.file):\(self.line): Last call was to zoo() with the expected input, but not with the output type StructB
                """
            }
        )
    }

    // MARK: - assertWasCalled after previousCall

    // TODO: Test for assertion failure messages and improve test coverage to 100%

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

    // TODO: Test for assertion failure messages and improve test coverage to 100%

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

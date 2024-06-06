//
// Created on 5/1/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import TestDRS
import XCTest

final class StubProvidingTests: XCTestCase {

    private let stubProvider = StubProvider()

    private let tokenStore = StaticTestingTokenStore()

    override func setUp() {
        StubProvider.generateStaticTestingToken()
            .store(in: tokenStore)
        super.setUp()
    }

    func testCallingMethodReturningVoid_WithoutStubbing() {
        // Methods returning void should not need to be stubbed
        return stubProvider.foo()
    }

    func testStubbingFunctionWithNoParameters() {
        stubProvider.setStub(for: stubProvider.foo, withSignature: "foo()", returning: 7)

        XCTAssertEqual(stubProvider.foo(), 7)
    }

    func testDynamicallyStubbingFunctionWithNoParameters() {
        var x = 1
        stubProvider.setDynamicStub(for: stubProvider.foo, withSignature: "foo()") {
            x * 7
        }

        XCTAssertEqual(stubProvider.foo(), 7)
        x = 7
        XCTAssertEqual(stubProvider.foo(), 49)
    }

    func testStubbingFunctionWithSingleParameter() {
        stubProvider.setStub(for: stubProvider.bar(paramOne:), withSignature: "bar(paramOne:)", returning: "Hello World")
        XCTAssertEqual(stubProvider.bar(paramOne: true), "Hello World")
    }

    func testDynamicallyStubbingFunctionWithSingleParameter() {
        stubProvider.setDynamicStub(for: stubProvider.bar(paramOne:), withSignature: "bar(paramOne:)") { paramOne in
            paramOne ? "Hello World" : "Goodbye World"
        }

        XCTAssertEqual(stubProvider.bar(paramOne: true), "Hello World")
        XCTAssertEqual(stubProvider.bar(paramOne: false), "Goodbye World")
    }

    func testStubbingFunctionWithMultipleParameters() {
        stubProvider.setStub(for: stubProvider.baz(paramOne:paramTwo:paramThree:), withSignature: "baz(paramOne:paramTwo:paramThree:)", returning: "Hello World")

        XCTAssertEqual(stubProvider.baz(paramOne: true, paramTwo: "foo", paramThree: 12), "Hello World")
    }

    func testDynamicallyStubbingFunctionWithMultipleParameters() {
        stubProvider.setDynamicStub(for: stubProvider.baz(paramOne:paramTwo:paramThree:), withSignature: "baz(paramOne:paramTwo:paramThree:)") { paramOne, paramTwo, paramThree in
            paramOne ? paramTwo : "\(paramThree)"
        }

        XCTAssertEqual(stubProvider.baz(paramOne: true, paramTwo: "Hello World", paramThree: 7), "Hello World")
        XCTAssertEqual(stubProvider.baz(paramOne: false, paramTwo: "Hello World", paramThree: 7), "7")
    }

    func testStubbingThrowingFunction_ReturningValue() {
        stubProvider.setStub(for: stubProvider.oof, withSignature: "oof()", returning: 7)

        XCTAssertEqual(try stubProvider.oof(), 7)
    }

    func testStubbingThrowingFunction_ThrowingError() {
        stubProvider.setStub(for: stubProvider.oof, withSignature: "oof()", throwing: StubProviderError())

        XCTAssertThrowsError(try stubProvider.oof()) { error in
            XCTAssertTrue(error is StubProviderError)
        }
    }

    func testDynamicallyStubbingThrowingFunction() {
        var shouldThrow = false
        stubProvider.setDynamicStub(for: stubProvider.oof, withSignature: "oof()") {
            guard !shouldThrow else { throw StubProviderError() }
            return 7
        }

        XCTAssertEqual(try stubProvider.oof(), 7)
        shouldThrow = true
        XCTAssertThrowsError(try stubProvider.oof()) { error in
            XCTAssertTrue(error is StubProviderError)
        }
    }

    func testStubbingGenericFunction() {
        stubProvider.setStub(for: stubProvider.rab(paramOne:), withSignature: "rab(paramOne:)", returning: true)
        stubProvider.setStub(for: stubProvider.rab(paramOne:), withSignature: "rab(paramOne:)", returning: 7)
        stubProvider.setStub(for: stubProvider.rab(paramOne:), withSignature: "rab(paramOne:)", returning: "Hello World")

        XCTAssertEqual(stubProvider.rab(paramOne: false), true)
        XCTAssertEqual(stubProvider.rab(paramOne: 1), 7)
        XCTAssertEqual(stubProvider.rab(paramOne: "Hello"), "Hello World")
    }

    func testDynamicallyStubbingGenericFunction() {
        stubProvider.setDynamicStub(for: stubProvider.rab(paramOne:), withSignature: "rab(paramOne:)") { paramOne -> Bool in
            !paramOne
        }
        stubProvider.setDynamicStub(for: stubProvider.rab(paramOne:), withSignature: "rab(paramOne:)") { paramOne -> Int in
            paramOne * 7
        }
        stubProvider.setDynamicStub(for: stubProvider.rab(paramOne:), withSignature: "rab(paramOne:)") { paramOne -> String in
            paramOne + " World"
        }

        XCTAssertEqual(stubProvider.rab(paramOne: false), true)
        XCTAssertEqual(stubProvider.rab(paramOne: 1), 7)
        XCTAssertEqual(stubProvider.rab(paramOne: "Hello"), "Hello World")
    }

    func testStubbingAsyncFunction() async {
        stubProvider.setStub(for: stubProvider.zab, withSignature: "zab()", returning: 7)

        let result = await stubProvider.zab()

        XCTAssertEqual(result, 7)
    }

    func testDynamicallyStubbingAsyncFunction() async {
        var x = 1
        stubProvider.setDynamicStub(for: stubProvider.zab, withSignature: "zab()") {
            x * 7
        }

        let resultOne = await stubProvider.zab()
        x = 7
        let resultTwo = await stubProvider.zab()

        XCTAssertEqual(resultOne, 7)
        XCTAssertEqual(resultTwo, 49)
    }

    func testStubbingAsyncThrowingFunction_ReturningValue() async throws {
        stubProvider.setStub(for: stubProvider.zoo, withSignature: "zoo()", returning: 7)

        let result = try await stubProvider.zoo()

        XCTAssertEqual(result, 7)
    }

    func testStubbingAsyncThrowingFunction_ThrowingError() async throws {
        stubProvider.setStub(for: stubProvider.zoo, withSignature: "zoo()", throwing: StubProviderError())

        do {
            _ = try await stubProvider.zoo()
            XCTFail("Expected error to be thrown")
        } catch _ as StubProviderError {
            // Expected
        } catch {
            XCTFail("Expected error to be StubProviderError")
        }
    }

    func testDynamicallyStubbingAsyncThrowingFunction_ReturningValue() async throws {
        var x = 1
        stubProvider.setDynamicStub(for: stubProvider.zoo, withSignature: "zoo()") {
            x * 7
        }

        let resultOne = try await stubProvider.zoo()
        x = 7
        let resultTwo = try await stubProvider.zoo()

        XCTAssertEqual(resultOne, 7)
        XCTAssertEqual(resultTwo, 49)
    }

    func testDynamicallyStubbingAsyncThrowingFunction_ThrowingError() async throws {
        var shouldThrow = false
        stubProvider.setDynamicStub(for: stubProvider.zoo, withSignature: "zoo()") {
            guard !shouldThrow else { throw StubProviderError() }
            return 7
        }

        let result = try await stubProvider.zoo()
        XCTAssertEqual(result, 7)

        shouldThrow = true

        do {
            _ = try await stubProvider.zoo()
            XCTFail("Expected error to be thrown")
        } catch _ as StubProviderError {
            // Expected
        } catch {
            XCTFail("Expected error to be StubProviderError")
        }
    }

    func testStubbingStaticFunction() {
        #stub(StubProvider.staticFoo, returning: 63)

        XCTAssertEqual(StubProvider.staticFoo(), 63)
    }

    func testStubbingStaticFunction2() {
        let token = StubProvider.generateStaticTestingToken()
        #stub(StubProvider.staticFoo, returning: 36)

        XCTAssertEqual(StubProvider.staticFoo(), 36)

        token.invalidate()
    }

}

private struct StubProvider: StubProviding {
    let stubRegistry = StubRegistry()

    func foo() {
        return stubOutput()
    }

    func foo() -> Int {
        stubOutput()
    }

    func bar(paramOne: Bool) -> String {
        stubOutput(for: paramOne)
    }

    func baz(paramOne: Bool, paramTwo: String, paramThree: Int) -> String {
        stubOutput(for: (paramOne, paramTwo, paramThree))
    }

    func oof() throws -> Int {
        try throwingStubOutput()
    }

    func rab<T>(paramOne: T) -> T {
        stubOutput(for: paramOne)
    }

    func zab() async -> Int {
        stubOutput()
    }

    func zoo() async throws -> Int {
        try throwingStubOutput()
    }

    static func staticFoo() -> Int {
        stubOutput()
    }
}

private struct StubProviderError: Error {}

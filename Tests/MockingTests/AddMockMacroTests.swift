//
// Created on 5/22/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Expectations
import Mocking
import TestDRSCore
import XCTest

final class AddMockMacroTests: XCTestCase {

    override func invokeTest() {
        withStaticTestingContext {
            super.invokeTest()
        }
    }

    @MainActor
    func testMockProtocolMethods() {
        let mockProtocol = MockSomeProtocol()

        #stub(mockProtocol.baz(paramOne:paramTwo:), returning: "World")
        #stub(MockSomeProtocol.oof, returning: "Wow")

        mockProtocol.foo()
        mockProtocol.bar(paramOne: 89)
        let bazOutput = mockProtocol.baz(paramOne: true, paramTwo: "Hello")
        let oofOutput = MockSomeProtocol.oof()

        #assertWasCalled(mockProtocol.foo)
            .exactlyOnce()

        #assertWasCalled(mockProtocol.bar(paramOne:), with: 89)
            .exactlyOnce()

        #assertWasCalled(mockProtocol.baz(paramOne:paramTwo:), with: true, "Hello")
            .exactlyOnce()

        XCTAssertEqual(bazOutput, "World")

        #assertWasCalled(MockSomeProtocol.oof)
            .exactlyOnce()
        XCTAssertEqual(oofOutput, "Wow")
    }

    @MainActor
    func testMockProtocolMethods_UsingAbbreviatedFunctionSignatures() {
        let mockProtocol = MockSomeProtocol()

        #stub(mockProtocol.baz, returning: "World")
        #stub(MockSomeProtocol.oof, returning: "Wow")

        mockProtocol.bar(paramOne: 89)
        let bazOutput = mockProtocol.baz(paramOne: true, paramTwo: "Hello")

        #assertWasCalled(mockProtocol.bar, with: 89)
            .exactlyOnce()

        #assertWasCalled(mockProtocol.baz, with: true, "Hello")
            .exactlyOnce()

        XCTAssertEqual(bazOutput, "World")
    }

    @MainActor
    func testMockProtocolProperties() {
        let mockProtocol = MockSomeProtocol()

        mockProtocol.x = "Hello World"
        mockProtocol.y = 89
        MockSomeProtocol.z = true

        XCTAssertEqual(mockProtocol.x, "Hello World")
        XCTAssertEqual(mockProtocol.y, 89)
        XCTAssertEqual(MockSomeProtocol.z, true)
    }

    @MainActor
    func testMockClassMethods() {
        let mockClass = MockSomeClass(x: "Hello World", y: 89)

        #stub(mockClass.baz(paramOne:paramTwo:), returning: "World")
        #stub(MockSomeClass.oof, returning: "Wow")

        mockClass.foo()
        mockClass.bar(paramOne: 89)
        let bazOutput = mockClass.baz(paramOne: true, paramTwo: "Hello")
        let oofOutput = MockSomeClass.oof()

        #assertWasCalled(mockClass.foo)
            .exactlyOnce()

        #assertWasCalled(mockClass.bar(paramOne:), with: 89)
            .exactlyOnce()

        #assertWasCalled(mockClass.baz(paramOne:paramTwo:), with: true, "Hello")
            .exactlyOnce()

        XCTAssertEqual(bazOutput, "World")

        #assertWasCalled(MockSomeClass.oof)
            .exactlyOnce()
        XCTAssertEqual(oofOutput, "Wow")
    }

    @MainActor
    func testMockClassProperties() {
        let mockClass = MockSomeClass(x: "Hello World", y: 89)

        XCTAssertEqual(mockClass.x, "Hello World")
        XCTAssertEqual(mockClass.y, 89)

        mockClass.x = "Goodbye"
        mockClass.y = 24
        MockSomeClass.z = false

        XCTAssertEqual(mockClass.x, "Goodbye")
        XCTAssertEqual(mockClass.y, 24)
        XCTAssertEqual(MockSomeClass.z, false)
    }

    @MainActor
    func testMockStructMethods() {
        let mockStruct = MockSomeStruct()

        #stub(mockStruct.baz(paramOne:paramTwo:), returning: "World")
        #stub(MockSomeStruct.oof, returning: "Wow")

        mockStruct.foo()
        mockStruct.bar(paramOne: 89)
        let bazOutput = mockStruct.baz(paramOne: true, paramTwo: "Hello")
        let oofOutput = MockSomeStruct.oof()

        #assertWasCalled(mockStruct.foo)
            .exactlyOnce()

        #assertWasCalled(mockStruct.bar(paramOne:), with: 89)
            .exactlyOnce()

        #assertWasCalled(mockStruct.baz(paramOne:paramTwo:), with: true, "Hello")
            .exactlyOnce()
        XCTAssertEqual(bazOutput, "World")

        #assertWasCalled(MockSomeStruct.oof)
            .exactlyOnce()
        XCTAssertEqual(oofOutput, "Wow")
    }

    @MainActor
    func testMockStructProperties() {
        var mockStruct = MockSomeStruct()

        mockStruct.x = "Hello World"
        mockStruct.y = 89
        MockSomeStruct.z = true

        XCTAssertEqual(mockStruct.x, "Hello World")
        XCTAssertEqual(mockStruct.y, 89)
        XCTAssertEqual(MockSomeStruct.z, true)
    }

}

extension AddMockMacroTests {

    @MainActor @AddMock
    protocol SomeProtocol {
        var x: String { get }
        var y: Int { get set }
        static var z: Bool { get }

        func foo()
        func bar(paramOne: Int)
        func baz<T>(paramOne: Bool, paramTwo: T) -> T

        static func oof() -> String
    }

    @MainActor @AddMock
    struct SomeStruct: SomeProtocol {

        private var a = "This should not be mocked"

        var x: String { "No" }
        var y: Int
        static var z: Bool = true

        init(y: Int) {
            self.y = y
        }

        func foo() {
            fatalError("Unimplemented")
        }

        func bar(paramOne: Int) {
            fatalError("Unimplemented")
        }

        func baz<T>(paramOne: Bool, paramTwo: T) -> T {
            fatalError("Unimplemented")
        }

        static func oof() -> String {
            fatalError("Unimplemented")
        }

    }

    @AddMock
    class SomeClass: NSObject, SomeProtocol {

        private var a = "This should not be mocked"

        @objc var x = "x"
        var y = 123
        class var z: Bool { true }

        init(x: String, y: Int) {
            self.x = x
            self.y = y
            self.x = "This should not be in the mock"
            self.y = 1_000_000
        }

        func foo() {
            fatalError("Unimplemented")
        }

        func bar(paramOne: Int) {
            fatalError("Unimplemented")
        }

        func baz<T>(paramOne: Bool, paramTwo: T) -> T {
            fatalError("Unimplemented")
        }

        class func oof() -> String {
            fatalError("Unimplemented")
        }

        final func rab() {
            fatalError("Unimplemented")
        }

    }

}

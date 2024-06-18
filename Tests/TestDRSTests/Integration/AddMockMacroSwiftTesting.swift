//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing

struct AddMockMacroSwiftTesting {

    typealias MockSomeProtocol = AddMockMacroTestTypes.MockSomeProtocol
    typealias MockSomeStruct = AddMockMacroTestTypes.MockSomeStruct
    typealias MockSomeClass = AddMockMacroTestTypes.MockSomeClass

    @Test @MainActor
    func testMockProtocolMethods() {
        withStaticTestingContext {
            let mockProtocol = MockSomeProtocol()

            #stub(mockProtocol.baz(paramOne:paramTwo:), returning: "World")
            #stub(MockSomeProtocol.oof, returning: "Wow")

            mockProtocol.foo()
            mockProtocol.bar(paramOne: 89)
            let bazOutput = mockProtocol.baz(paramOne: true, paramTwo: "Hello")
            let oofOutput = MockSomeProtocol.oof()

            #expectWasCalled(mockProtocol.foo)
                .exactlyOnce()

            #expectWasCalled(mockProtocol.bar(paramOne:), with: 89)
                .exactlyOnce()

            #expectWasCalled(mockProtocol.baz(paramOne:paramTwo:), with: true, "Hello")
                .exactlyOnce()

            #expect(bazOutput == "World")

            #expectWasCalled(MockSomeProtocol.oof)
                .exactlyOnce()
            #expect(oofOutput == "Wow")
        }
    }

    @Test @MainActor
    func testMockProtocolMethods_UsingAbbreviatedFunctionSignatures() {
        withStaticTestingContext {
            let mockProtocol = MockSomeProtocol()

            #stub(mockProtocol.baz, returning: "World")
            #stub(MockSomeProtocol.oof, returning: "Wow")

            mockProtocol.bar(paramOne: 89)
            let bazOutput = mockProtocol.baz(paramOne: true, paramTwo: "Hello")

            #expectWasCalled(mockProtocol.bar, with: 89)
                .exactlyOnce()

            #expectWasCalled(mockProtocol.baz, with: true, "Hello")
                .exactlyOnce()

            #expect(bazOutput == "World")
        }
    }

    @Test @MainActor
    func testMockProtocolProperties() {
        withStaticTestingContext {
            let mockProtocol = MockSomeProtocol()

            mockProtocol.x = "Hello World"
            mockProtocol.y = 89
            MockSomeProtocol.z = true

            #expect(mockProtocol.x == "Hello World")
            #expect(mockProtocol.y == 89)
            #expect(MockSomeProtocol.z == true)
        }
    }

    @Test @MainActor
    func testMockClassMethods() {
        withStaticTestingContext {
            let mockClass = MockSomeClass(x: "Hello World", y: 89)

            #stub(mockClass.baz(paramOne:paramTwo:), returning: "World")
            #stub(MockSomeClass.oof, returning: "Wow")

            mockClass.foo()
            mockClass.bar(paramOne: 89)
            let bazOutput = mockClass.baz(paramOne: true, paramTwo: "Hello")
            let oofOutput = MockSomeClass.oof()

            #expectWasCalled(mockClass.foo)
                .exactlyOnce()

            #expectWasCalled(mockClass.bar(paramOne:), with: 89)
                .exactlyOnce()

            #expectWasCalled(mockClass.baz(paramOne:paramTwo:), with: true, "Hello")
                .exactlyOnce()

            #expect(bazOutput == "World")

            #expectWasCalled(MockSomeClass.oof)
                .exactlyOnce()
            #expect(oofOutput == "Wow")
        }
    }

    @Test @MainActor
    func testMockClassProperties() {
        withStaticTestingContext {
            let mockClass = MockSomeClass(x: "Hello World", y: 89)

            #expect(mockClass.x == "Hello World")
            #expect(mockClass.y == 89)

            mockClass.x = "Goodbye"
            mockClass.y = 24
            MockSomeClass.z = false

            #expect(mockClass.x == "Goodbye")
            #expect(mockClass.y == 24)
            #expect(MockSomeClass.z == false)
        }
    }

    @Test @MainActor
    func testMockStructMethods() {
        withStaticTestingContext {
            let mockStruct = MockSomeStruct()

            #stub(mockStruct.baz(paramOne:paramTwo:), returning: "World")
            #stub(MockSomeStruct.oof, returning: "Wow")

            mockStruct.foo()
            mockStruct.bar(paramOne: 89)
            let bazOutput = mockStruct.baz(paramOne: true, paramTwo: "Hello")
            let oofOutput = MockSomeStruct.oof()

            #expectWasCalled(mockStruct.foo)
                .exactlyOnce()

            #expectWasCalled(mockStruct.bar(paramOne:), with: 89)
                .exactlyOnce()

            #expectWasCalled(mockStruct.baz(paramOne:paramTwo:), with: true, "Hello")
                .exactlyOnce()
            #expect(bazOutput == "World")

            #expectWasCalled(MockSomeStruct.oof)
                .exactlyOnce()
            #expect(oofOutput == "Wow")
        }
    }

    @Test @MainActor
    func testMockStructProperties() {
        withStaticTestingContext {
            var mockStruct = MockSomeStruct()

            mockStruct.x = "Hello World"
            mockStruct.y = 89
            MockSomeStruct.z = true

            #expect(mockStruct.x == "Hello World")
            #expect(mockStruct.y == 89)
            #expect(MockSomeStruct.z == true)
        }
    }

}

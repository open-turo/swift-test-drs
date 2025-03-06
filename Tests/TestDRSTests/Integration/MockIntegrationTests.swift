//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS
import Testing

struct MockIntegrationTests {

    private typealias TestableMockType = Mock & SomeProtocol & Sendable
    private typealias AddMockToProtocol = MockSomeProtocol
    private typealias AddMockToStruct = MockSomeStruct
    private typealias AddMockToClass = MockSomeClass

    private static var mocks: [any TestableMockType] {
        [
            AddMockToProtocol().with(\.id, UUID()),
            MockStruct().with(\.id, UUID()),
            AddMockToClass(x: "", y: 0).with(\.id, UUID()),
            MockStruct().with(\.id, UUID()),
            MockClass().with(\.id, UUID())
        ]
    }

    @Test(arguments: mocks)
    @MainActor
    private func testMockMethods(mock: any TestableMockType) throws {
        withStaticTestingContext {
            let MockType = type(of: mock)

            #stub(mock.baz(paramOne:paramTwo:), returning: "World")
            #stub(mock.bam, throwing: MockError())
            #stub(MockType.oof, returning: "Wow")

            mock.foo()
            mock.bar(paramOne: 89)
            let bazOutput = mock.baz(paramOne: true, paramTwo: "Hello")
            let oofOutput = MockType.oof()

            #expectWasCalled(mock.foo)
                .exactlyOnce()

            #expectWasCalled(mock.bar(paramOne:), with: 89)
                .exactlyOnce()

            #expectWasCalled(mock.baz(paramOne:paramTwo:), with: true, "Hello")
                .exactlyOnce()

            #expect(bazOutput == "World")

            #expect(throws: MockError.self) {
                try mock.bam()
            }
            #expectWasCalled(mock.bam)
                .exactlyOnce()

            #expectWasCalled(MockType.oof)
                .exactlyOnce()
            #expect(oofOutput == "Wow")
        }
    }

    @Test(arguments: mocks)
    @MainActor
    private func testMockMethods_UsingAbbreviatedFunctionSignatures(mock: any TestableMockType) {
        withStaticTestingContext {
            let MockType = type(of: mock)

            #stub(mock.baz, returning: "World")
            #stub(MockType.oof, returning: "Wow")

            mock.bar(paramOne: 89)
            let bazOutput = mock.baz(paramOne: true, paramTwo: "Hello")

            #expectWasCalled(mock.bar, with: 89)
                .exactlyOnce()

            #expectWasCalled(mock.baz, with: true, "Hello")
                .exactlyOnce()

            #expect(bazOutput == "World")
        }
    }

    // Unfortunately we need concrete types in order to set the properties of the mocks,
    // so we can't utilize arguments within our @Test.

    @Test @MainActor
    func testMockProtocolProperties() {
        withStaticTestingContext {
            let mockProtocol = AddMockToProtocol()

            mockProtocol.x = "Hello World"
            mockProtocol.y = 89
            AddMockToProtocol.z = true

            #expect(mockProtocol.x == "Hello World")
            #expect(mockProtocol.y == 89)
            #expect(AddMockToProtocol.z == true)
        }
    }

    @Test @MainActor
    func testAddToMockClassProperties() {
        withStaticTestingContext {
            let mockClass = AddMockToClass()

            mockClass.x = "Hello World"
            mockClass.y = 89
            AddMockToClass.z = true

            #expect(mockClass.x == "Hello World")
            #expect(mockClass.y == 89)
            #expect(AddMockToClass.z == true)
        }
    }

    @Test @MainActor
    func testAddMockToStructProperties() {
        withStaticTestingContext {
            var mockStruct = AddMockToStruct()

            mockStruct.x = "Hello World"
            mockStruct.y = 89
            AddMockToStruct.z = true

            #expect(mockStruct.x == "Hello World")
            #expect(mockStruct.y == 89)
            #expect(AddMockToStruct.z == true)
        }
    }

    @Test @MainActor
    func testMockClassProperties() {
        withStaticTestingContext {
            let mockClass = MockClass()

            mockClass.x = "Hello World"
            mockClass.y = 89
            MockClass.z = true

            #expect(mockClass.x == "Hello World")
            #expect(mockClass.y == 89)
            #expect(MockClass.z == true)
        }
    }

    @Test @MainActor
    func testMockStructProperties() {
        withStaticTestingContext {
            var mockStruct = MockStruct()

            mockStruct.x = "Hello World"
            mockStruct.y = 89
            MockStruct.z = true

            #expect(mockStruct.x == "Hello World")
            #expect(mockStruct.y == 89)
            #expect(MockStruct.z == true)
        }
    }

}

private extension StubProviding {

    func with<T>(_ keyPath: KeyPath<Self, T>, _ value: T) -> Self {
        setStub(value: value, forPropertyNamed: "\(keyPath)".components(separatedBy: ".").last!)
        return self
    }

}

// MARK: - Test Types

private struct MockError: Error {}

@AddMock
private protocol SomeProtocol: Sendable, Identifiable {
    var id: UUID { get }
    var x: String { get }
    var y: Int { get set }
    static var z: Bool { get }

    func foo()
    func bar(paramOne: Int)
    func baz<T>(paramOne: Bool, paramTwo: T) -> T
    func bam() throws

    static func oof() -> String

    init(x: String, y: Int)
}

@AddMock
private struct SomeStruct: SomeProtocol {

    let id = UUID()

    private var a = "This should not be mocked"

    var x: String { "No" }
    var y: Int
    nonisolated(unsafe) static var z: Bool = true

    init(x: String, y: Int) {
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

    func bam() throws {
        fatalError("Unimplemented")
    }

    static func oof() -> String {
        fatalError("Unimplemented")
    }

}

@AddMock
private class SomeClass: NSObject, SomeProtocol, @unchecked Sendable {

    var id = UUID()

    private let a = "This should not be mocked"

    @objc var x = "x"
    var y = 123
    class var z: Bool { true }

    required init(x: String, y: Int) {
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

    func bam() throws {
        fatalError("Unimplemented")
    }

    class func oof() -> String {
        fatalError("Unimplemented")
    }

    final func rab() {
        fatalError("Unimplemented")
    }

}

extension MockSomeClass {
    convenience init() {
        self.init(x: "", y: 0)
    }
}

@Mock
private struct MockStruct: SomeProtocol {
    var id: UUID
    var x: String
    var y: Int

    static var z: Bool

    init() {}

    init(x: String, y: Int) {
        self.x = x
        self.y = y
    }

    func foo()
    func bar(paramOne: Int)
    func baz<T>(paramOne: Bool, paramTwo: T) -> T
    func bam() throws
    static func oof() -> String
}

@Mock
private class MockClass: SomeProtocol, @unchecked Sendable {
    var id: UUID
    var x: String
    var y: Int

    static var z: Bool

    init() {}

    required init(x: String, y: Int) {
        self.x = x
        self.y = y
    }

    func foo()
    func bar(paramOne: Int)
    func baz<T>(paramOne: Bool, paramTwo: T) -> T
    func bam() throws
    static func oof() -> String
}

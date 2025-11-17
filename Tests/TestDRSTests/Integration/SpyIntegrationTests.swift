//
// Created on 11/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS
import Testing

struct SpyIntegrationTests {

    private typealias TestableSpyType = Spy & SomeProtocol & Sendable

    private static var spies: [any TestableSpyType] {
        [
            SpySomeProtocol(real: SomeStruct()),
            SpySomeStruct(real: SomeStruct()),
            SpySomeClass(x: "Hello World!", y: 3) // Class spies are subclasses, not wrappers
        ]
    }

    @Test(arguments: spies)
    @MainActor
    private func testSpyMethods(spy: any TestableSpyType) {
        withStaticTestingContext {
            let SpyType = type(of: spy)

            spy.foo()
            spy.bar(paramOne: 89)
            let bazOutput = spy.baz(paramOne: true, paramTwo: "Hello")
            try! spy.bam()
            let oofOutput = SpyType.oof()

            #expectWasCalled(spy.foo)
                .exactlyOnce()

            #expectWasCalled(spy.bar(paramOne:), with: 89)
                .exactlyOnce()

            #expectWasCalled(spy.baz(paramOne:paramTwo:), with: true, "Hello")
                .exactlyOnce()

            #expect(bazOutput == "Hello")

            #expectWasCalled(spy.bam)
                .exactlyOnce()

            #expectWasCalled(SpyType.oof)
                .exactlyOnce()
            #expect(oofOutput == "Static Wow")
        }
    }

    @Test(arguments: spies)
    @MainActor
    private func testSpyProperties(spy: any TestableSpyType) {
        withStaticTestingContext {
            let SpyType = type(of: spy)

            #expect(spy.x == "Hello World!")
            #expect(spy.y == 3)

            #expect(SpyType.z == true)

            SpyType.z = false
            #expect(SpyType.z == false)

            // Since this uses the real, shared, static property, we need to reset it
            SpyType.z = true
        }
    }

}

// MARK: - Test Types

private struct SpyError: Error {}

@AddSpy
private protocol SomeProtocol: Sendable, Identifiable {
    var id: UUID { get }
    var x: String { get }
    var y: Int { get }
    static var z: Bool { get set }

    func foo()
    func bar(paramOne: Int)
    func baz<T>(paramOne: Bool, paramTwo: T) -> T
    func bam() throws

    static func oof() -> String
}

@AddSpy
private struct SomeStruct: SomeProtocol {
    let id = UUID()

    let x = "Hello World!"

    let y = 3

    nonisolated(unsafe) static var z = true

    func foo() {}

    func bar(paramOne: Int) {}

    func baz<T>(paramOne: Bool, paramTwo: T) -> T {
        return paramTwo
    }

    func bam() throws {}

    static func oof() -> String {
        return "Static Wow"
    }

}

@AddSpy
private class SomeClass: SomeProtocol, @unchecked Sendable {
    var id = UUID()
    var x: String
    var y: Int
    nonisolated(unsafe) static var z: Bool = true

    init(x: String = "", y: Int = 0) {
        self.x = x
        self.y = y
    }

    func foo() {}

    func bar(paramOne: Int) {}

    func baz<T>(paramOne: Bool, paramTwo: T) -> T {
        return paramTwo
    }

    func bam() throws {}

    class func oof() -> String {
        return "Static Wow"
    }
}

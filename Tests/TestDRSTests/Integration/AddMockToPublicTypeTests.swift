//
// Created on 3/6/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS
import Testing

// Verifying that the mocks are generated properly by lack of build errors.

@AddMock
public protocol SomePublicProtocol: Sendable, Identifiable {
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
public struct SomePublicStruct: SomePublicProtocol {

    public let id = UUID()

    private var a = "This should not be mocked"

    public var x: String { "No" }
    public var y: Int
    nonisolated(unsafe) public static var z: Bool = true

    public init(x: String, y: Int) {
        self.y = y
    }

    public func foo() {
        fatalError("Unimplemented")
    }

    public func bar(paramOne: Int) {
        fatalError("Unimplemented")
    }

    public func baz<T>(paramOne: Bool, paramTwo: T) -> T {
        fatalError("Unimplemented")
    }

    public func bam() throws {
        fatalError("Unimplemented")
    }

    public static func oof() -> String {
        fatalError("Unimplemented")
    }

}

@AddMock
public class SomePublicClass: NSObject, SomePublicProtocol, @unchecked Sendable {

    public var id = UUID()

    private let a = "This should not be mocked"

    @objc public var x = "x"
    public var y = 123
    public class var z: Bool { true }

    public required init(x: String, y: Int) {
        self.x = x
        self.y = y
        self.x = "This should not be in the mock"
        self.y = 1_000_000
    }

    public func foo() {
        fatalError("Unimplemented")
    }

    public func bar(paramOne: Int) {
        fatalError("Unimplemented")
    }

    public func baz<T>(paramOne: Bool, paramTwo: T) -> T {
        fatalError("Unimplemented")
    }

    public func bam() throws {
        fatalError("Unimplemented")
    }

    public class func oof() -> String {
        fatalError("Unimplemented")
    }

    public final func rab() {
        fatalError("Unimplemented")
    }

}

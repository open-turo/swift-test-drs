//
// Created on 6/18/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS

struct AddMockMacroTestTypes {

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

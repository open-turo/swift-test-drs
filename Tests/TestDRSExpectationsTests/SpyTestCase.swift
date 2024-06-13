//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRSCore
import XCTest

open class SpyTestCase: XCTestCase, Spy {

    public let blackBox = BlackBox()

    private var second = 0

    public static func callTime(second: Int) -> Date {
        let startDateComponents = DateComponents(year: 2018, month: 6, day: 15, hour: 0, second: second)
        return Calendar.autoupdatingCurrent.date(from: startDateComponents)!
    }

    public func foo() {
        defer { second += 1 }
        recordCall(at: .functionCallTime(second: second))
    }

    public func bar(paramOne: Bool) {
        defer { second += 1 }
        recordCall(with: paramOne, at: .functionCallTime(second: second))
    }

    public func baz(paramOne: Bool?) {
        defer { second += 1 }
        recordCall(with: paramOne, at: .functionCallTime(second: second))
    }

    public func oof(paramOne: Bool, paramTwo: Int) {
        defer { second += 1 }
        recordCall(with: (paramOne, paramTwo), at: .functionCallTime(second: second))
    }

    public func rab(paramOne: Bool, paramTwo: Int?, paramThree: String?) {
        defer { second += 1 }
        recordCall(with: (paramOne, paramTwo, paramThree), at: .functionCallTime(second: second))
    }

    @discardableResult
    public func zab<T>(paramOne: T) -> T {
        defer { second += 1 }
        recordCall(with: paramOne, at: .functionCallTime(second: second), returning: T.self)
        return paramOne
    }

    public func zoo<T: SomeProtocol>() -> T {
        defer { second += 1 }
        recordCall(at: .functionCallTime(second: second), returning: T.self)
        return T()
    }

    public static func staticFoo() {
        recordCall()
    }

}

public protocol SomeProtocol {
    init()
}

extension Date {
    public static func functionCallTime(second: Int) -> Date {
        let startDateComponents = DateComponents(year: 2018, month: 6, day: 15, hour: 0, minute: 0, second: second)
        return Calendar.autoupdatingCurrent.date(from: startDateComponents)!
    }
}

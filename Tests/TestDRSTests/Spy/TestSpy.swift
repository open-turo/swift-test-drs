//
// Created on 7/5/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS

final class TestSpy: Spy, @unchecked Sendable {

    let blackBox = BlackBox(mockType: TestSpy.self)

    private var second = 0

    static func callTime(second: Int) -> Date {
        let startDateComponents = DateComponents(year: 2018, month: 6, day: 15, hour: 0, second: second)
        return Calendar.autoupdatingCurrent.date(from: startDateComponents)!
    }

    func foo() {
        defer { second += 1 }
        recordCall(at: .functionCallTime(second: second))
    }

    func bar(paramOne: Bool) {
        defer { second += 1 }
        recordCall(with: paramOne, at: .functionCallTime(second: second))
    }

    func baz(paramOne: Bool?) {
        defer { second += 1 }
        recordCall(with: paramOne, at: .functionCallTime(second: second))
    }

    func oof(paramOne: Bool, paramTwo: Int) {
        defer { second += 1 }
        recordCall(with: (paramOne, paramTwo), at: .functionCallTime(second: second))
    }

    func rab(paramOne: Bool, paramTwo: Int?, paramThree: String?) {
        defer { second += 1 }
        recordCall(with: (paramOne, paramTwo, paramThree), at: .functionCallTime(second: second))
    }

    @discardableResult
    func zab<T>(paramOne: T) -> T {
        defer { second += 1 }
        recordCall(with: paramOne, at: .functionCallTime(second: second), returning: T.self)
        return paramOne
    }

    func zoo<T: SomeProtocol>() -> T {
        defer { second += 1 }
        recordCall(at: .functionCallTime(second: second), returning: T.self)
        return T()
    }

    static func staticFoo() {
        recordCall()
    }

}

extension Date {
    static func functionCallTime(second: Int) -> Date {
        let startDateComponents = DateComponents(year: 2018, month: 6, day: 15, hour: 0, minute: 0, second: second)
        return Calendar.autoupdatingCurrent.date(from: startDateComponents)!
    }
}

extension TestSpy {

    protocol SomeProtocol {
        init()
    }

    struct StructA: SomeProtocol {}

    struct StructB: SomeProtocol {}

}

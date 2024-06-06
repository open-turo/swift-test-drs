//
// Created on 5/16/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

extension Spy {

    static func register(staticBlackBox: BlackBox) {
        BlackBox.register(staticStorage: staticBlackBox, for: Self.self)
    }

    static func getStaticBlackBox(file: StaticString? = nil, line: UInt? = nil) -> BlackBox {
        guard let blackBox = BlackBox.staticStorage(for: Self.self) else {
            let blackBox = BlackBox()
            blackBox.reportFailure(message: "You must generate a static testing token using `\(Self.self).generateStaticTestingToken()` and hold on to it for the duration of the test in order to utilize Spy functionality with static members of \(Self.self).", file: file, line: line)
            return blackBox
        }

        return blackBox
    }

}

// MARK: - BlackBox + StaticStorageRegistering
extension BlackBox: StaticStorageRegistering {

    static var staticStorageRegistry: [String: WeakWrapper<BlackBox>] = [:]

}

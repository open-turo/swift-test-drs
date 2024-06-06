//
// Created on 6/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

class WeakWrapper<Value: AnyObject> {

    weak var wrappedValue: Value?

    init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

}

//
// Created on 5/17/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// Defines possible positions of a function call relative to other function calls recorded by a Spy.
public enum FunctionCallPosition {
    /// The function was the first to be recorded by a Spy.
    case first
    /// The function was the last to be recorded by a Spy.
    case last
    /// The function was recorded after the specified function call.
    case after(_ previousCall: any FunctionCall)
    /// The function was recorded immediately after the specified function call.
    case immediatelyAfter(_ previousCall: any FunctionCall)
}

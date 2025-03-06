//
// Created on 7/5/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// TestDRS supports using ranges that have a lower bound in order to verify call counts.
/// This protocol allows for using `PartialRangeFrom`, `Range`, or `ClosedRange`.
public protocol LowerBoundProviding {
    associatedtype Bound
    var lowerBound: Bound { get }
}

/// Extends `PartialRangeFrom` to conform to `LowerBoundProviding`.
///
/// This allows ranges like `5...` to be used when specifying call count expectations.
extension PartialRangeFrom: LowerBoundProviding {}

/// Extends `Range` to conform to `LowerBoundProviding`.
///
/// This allows ranges like `5..<10` to be used when specifying call count expectations.
extension Range: LowerBoundProviding {}

/// Extends `ClosedRange` to conform to `LowerBoundProviding`.
///
/// This allows ranges like `5...10` to be used when specifying call count expectations.
extension ClosedRange: LowerBoundProviding {}

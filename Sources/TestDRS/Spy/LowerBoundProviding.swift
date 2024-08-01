//
// Created on 7/5/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

public protocol LowerBoundProviding {
    associatedtype Bound
    var lowerBound: Bound { get }
}

extension PartialRangeFrom: LowerBoundProviding {}
extension Range: LowerBoundProviding {}
extension ClosedRange: LowerBoundProviding {}

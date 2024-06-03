//
// Created on 5/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// The number of function calls that matching is supported for.
public protocol FunctionCallAmountMatching {}

/// Supports matching more than one call.
public protocol MatchingMultiple: FunctionCallAmountMatching {}

/// Matches either zero or one calls.
public enum MatchingSingle: FunctionCallAmountMatching {}

/// Matches a certain number of calls from zero to infinity.
public enum MatchingSomeAmount: MatchingMultiple {}

/// Matches any number of calls from zero to infinity.
public enum MatchingAnyAmount: MatchingMultiple {}

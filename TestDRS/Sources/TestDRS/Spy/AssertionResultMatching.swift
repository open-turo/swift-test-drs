//
// Created on 5/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// The type of matching that an assertion supports.
public protocol AssertionResultMatching {}

/// An assertion result that supports matching more than one call.
public protocol AssertionResultMatchingMultiple: AssertionResultMatching {}

/// Matches either zero or one calls.
public enum MatchingSingle: AssertionResultMatching {}

/// Matches a certain number of calls from zero to infinity.
public enum MatchingSomeAmount: AssertionResultMatchingMultiple {}

/// Matches any number of calls from zero to infinity.
public enum MatchingAnyAmount: AssertionResultMatchingMultiple {}

//
// Created on 5/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// The type of matching that an assertion supports.
public protocol AssertionResultMatching {}

/// Matches either zero or one calls.
public enum MatchingSingle: AssertionResultMatching {}

/// Matches any number of calls from zero to infinity.
public enum MatchingMultiple: AssertionResultMatching {}

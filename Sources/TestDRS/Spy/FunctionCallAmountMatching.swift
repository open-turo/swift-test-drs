//
// Created on 5/29/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

/// A protocol that represents different ways of matching function call counts during verification.
///
/// This protocol serves as a base for more specific matching strategies that can be used
/// to verify function calls in different ways. It's part of the type system that ensures
/// verification methods are used with the appropriate matching strategies.
public protocol FunctionCallAmountMatching {}

/// A protocol for matching strategies that handle at most a single function call.
///
/// Types conforming to this protocol can be used with verification methods that
/// only need to match or analyze a single function call from a call history.
public protocol MatchingSingle: FunctionCallAmountMatching {}

/// A protocol for matching strategies that can handle multiple function calls.
///
/// Types conforming to this protocol can be used with verification methods that
/// need to match or analyze multiple function calls from a call history.
public protocol MatchingMultiple: FunctionCallAmountMatching {}

/// A matching strategy that examines only the first call in a sequence of calls.
///
/// This strategy is useful when you only care about the first time a function was called,
/// even if it was called multiple times. It will match the first call that satisfies
/// the verification criteria, regardless of how many times the function was called.
public enum MatchingFirst: MatchingSingle {}

/// A matching strategy that requires exactly one function call.
///
/// This strategy is used when a function should be called exactly once. Verification
/// will should fail if the function wasn't called at all or was called more than once.
public enum MatchingOne: MatchingSingle {}

/// A matching strategy that verifies a specific number or range of function calls.
///
/// This strategy is used when you need to verify that a function was called a specific
/// number of times, such as exactly 3 times or between 2 and 5 times. It allows for
/// more precise control over the expected call count.
public enum MatchingSomeAmount: MatchingMultiple {}

/// A matching strategy that accepts any number of function calls, including zero.
///
/// This strategy is the most permissive and is useful when you want to inspect the
/// calls that were made without having any specific expectations about how many times
/// the function should have been called.
public enum MatchingAnyAmount: MatchingMultiple {}

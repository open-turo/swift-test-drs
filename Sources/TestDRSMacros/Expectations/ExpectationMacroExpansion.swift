//
// Created on 5/8/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

public struct ExpectWasCalledMacro: FunctionCallVerificationMacro {
    static let instanceVerificationName = expectWasCalled
    // TODO: There seems to a bug in macro expansion that necessitates static expectations having a different name,
    // we should see if it is possible to use the same name at some point.
    static let staticVerificationName = expectStaticFunctionWasCalled
}

public struct ExpectWasNotCalledMacro: FunctionCallVerificationMacro {
    static let instanceVerificationName = expectWasNotCalled
    static let staticVerificationName = expectStaticFunctionWasNotCalled
}

private extension FunctionCallVerificationMacro {
    static var expectWasCalled: String { "expectWasCalled" }
    static var expectWasNotCalled: String { "expectWasNotCalled" }
    static var expectStaticFunctionWasCalled: String { "expectStaticFunctionWasCalled" }
    static var expectStaticFunctionWasNotCalled: String { "expectStaticFunctionWasNotCalled" }
}

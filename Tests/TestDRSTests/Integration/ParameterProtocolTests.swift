//
// Created on 1/27/25.
// Copyright © 2025 Turo Open Source. All rights reserved.
//

import TestDRS
import Testing

/// Tests for verifying behavior when the input to a method uses a parameter constrained to a protocol,
/// but the function itself is not generic over that parameter.
struct ProtocolConstrainedNonGenericParameterTests {

    @Test
    func testWithSingleProtocolConstrainedParameter() {
        let myMock = MyMock()
        let parameter = ParamStruct()

        // Since foo isn't generic over `ParamProtocol`, the input will be recorded as a `ParamProtocol` and not a `ParamStruct`
        myMock.foo(paramOne: parameter)

        // Without specifying the input type, it resolves to `ParamProtocol`
        #expectWasCalled(myMock.foo)

        // When the input type is specified as `ParamStruct`, the expectation can be checked with the concrete type
        #expectWasCalled(myMock.foo, taking: ParamStruct.self)

        // When the expected input is specified, again the expectation can be checked with the concrete type
        #expectWasCalled(myMock.foo, with: parameter)
    }

    @Test
    func testWithMultipleProtocolConstrainedParameters() {
        let myMock = MyMock()
        let parameter = ParamStruct()

        myMock.bar(paramOne: parameter, paramTwo: parameter)

        #expectWasCalled(myMock.bar)
        #expectWasCalled(myMock.bar, taking: (ParamStruct, ParamStruct).self)
        #expectWasCalled(myMock.bar, with: parameter, parameter)
    }

}

private protocol ParamProtocol {}
private struct ParamStruct: ParamProtocol, Equatable {}

@Mock
private struct MyMock {
    fileprivate func foo(paramOne: ParamProtocol)
    fileprivate func bar(paramOne: ParamProtocol, paramTwo: ParamProtocol)
}

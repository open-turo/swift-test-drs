//
// Created on 5/4/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS

@Mock
protocol NetworkClientProtocol {
    func get(url: URL) throws -> Data
}

@Mock
struct NetworkClientStruct: NetworkClientProtocol {
    func get(url: URL) throws -> Data {
        fatalError()
        // Real implementation would make a network request and return the data
    }
}

@Mock
class NetworkClientClass: NetworkClientProtocol {
    func get(url: URL) throws -> Data {
        fatalError()
        // Real implementation would make a network request and return the data
    }
}

enum NetworkClientError: Error {
    case noNetworkConnection
    case serverError
}

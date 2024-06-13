//
// Created on 5/4/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS

@AddMock
protocol NetworkClientProtocol {
    func get(url: URL) throws -> Data
}

@AddMock
struct NetworkClientStruct: NetworkClientProtocol {
    func get(url: URL) throws -> Data {
        fatalError()
        // Real implementation would make a network request and return the data
    }
}

@AddMock
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

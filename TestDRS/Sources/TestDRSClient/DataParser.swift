//
// Created on 5/4/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation
import TestDRS

@Mock
protocol DataParserProtocol {
    func parse<T: Decodable>(_ data: Data) throws -> T
}

@Mock
struct DataParserStruct: DataParserProtocol {
    func parse<T: Decodable>(_ data: Data) throws -> T {
        fatalError()
        // Real implementation would parse the data into the specified Decodable type
    }
}

@Mock
class DataParserClass: DataParserProtocol {
    func parse<T: Decodable>(_ data: Data) throws -> T {
        fatalError()
        // Real implementation would parse the data into the specified Decodable type
    }
}

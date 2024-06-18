//
// Created on 6/13/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import ExampleClient
import Foundation
import TestDRS
import Testing

struct WeatherServiceSwiftTesting {

    @Test
    func testFetchingWeather() throws {
        // Using protocol-based mocks
        let networkClient = MockNetworkClientProtocol()
        let dataParser = MockDataParserProtocol()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)

        let data = try #require("Hello World".data(using: .utf8))
        let expectedURL = try #require(URL(string: "https://api.weather.com/v1/location/charleston/forecast/daily/5day.json"))

        #stub(networkClient.get(url:), returning: data)
        #stub(dataParser.parse(_:), returning: Weather(temperature: 72, description: "Sunny"))

        let weather = try weatherService.fetchWeather(for: "charleston")

        #expect(weather.temperature == 72)
        #expect(weather.description == "Sunny")

        #expectWasCalled(networkClient.get, with: expectedURL)
            .exactlyOnce()

        #expectWasCalled(dataParser.parse, with: data, returning: Weather.self)
            .exactlyOnce()
    }

    @Test
    func testFetchingWeather_WithNetworkClientError() throws {
        // Using struct-based mocks
        let networkClient = MockNetworkClientStruct()
        let dataParser = MockDataParserStruct()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)

        #stub(networkClient.get, throwing: NetworkClientError.serverError)
        #stub(dataParser.parse, returning: Weather(temperature: 72, description: "Sunny"))

        #expect(throws: NetworkClientError.serverError) {
            try weatherService.fetchWeather(for: "charleston")
        }

        #expectWasNotCalled(dataParser.parse, returning: Weather.self)
    }

    @Test
    func testFetchingWeather_WithDataParserError() throws {
        // Using class-based mocks
        let networkClient = MockNetworkClientClass()
        let dataParser = MockDataParserClass()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)

        let data = try #require("Hello World".data(using: .utf8))

        #stub(networkClient.get, returning: data)
        #stub(dataParser.parse, using: { _ -> Weather in
            throw DataParsingError.errorParsingData
        })

        #expect(throws: DataParsingError.errorParsingData) {
            try weatherService.fetchWeather(for: "charleston")
        }
    }

}

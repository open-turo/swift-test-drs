//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import TestDRS
@testable import TestDRSClient
import XCTest

final class TestDRSClientTests: XCTestCase {

    func testWeatherService_WithMockProtocols() throws {
        let networkClient = MockNetworkClientProtocol()
        let dataParser = MockDataParserProtocol()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)
        try testWeatherService(
            weatherService,
            networkClient: networkClient,
            dataParser: dataParser
        )
    }

    func testWeatherService_WithMockStructs() throws {
        let networkClient = MockNetworkClientStruct()
        let dataParser = MockDataParserStruct()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)
        try testWeatherService(
            weatherService,
            networkClient: networkClient,
            dataParser: dataParser
        )
    }

    func testWeatherService_WithMockClasses() throws {
        let networkClient = MockNetworkClientClass()
        let dataParser = MockDataParserClass()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)
        try testWeatherService(
            weatherService,
            networkClient: networkClient,
            dataParser: dataParser
        )
    }

    func testWeatherService(
        _ weatherService: WeatherServiceProtocol,
        networkClient: NetworkClientProtocol & Spy & StubProviding,
        dataParser: DataParserProtocol & Spy & StubProviding
    ) throws {
        let data = try XCTUnwrap("Hello World".data(using: .utf8))
        let expectedURL = try XCTUnwrap(URL(string: "https://api.weather.com/v1/location/charleston/forecast/daily/5day.json"))

        // TODO: Use stub macro
        networkClient.setStub(for: networkClient.get(url:), withSignature: "get(url:)", returning: data)
        // TODO: Use stub macro
        dataParser.setStub(for: dataParser.parse(_:), withSignature: "parse(_:)", returning: Weather(temperature: 72, description: "Sunny"))

        let weather = try weatherService.fetchWeather(for: "charleston")

        XCTAssertEqual(weather.temperature, 72)
        XCTAssertEqual(weather.description, "Sunny")

        // TODO: Use assert macro
        networkClient.assertWasCalled("get(url:)", with: expectedURL)
        // TODO: Use assert macro
        dataParser.assertWasCalled("parse(_:)", with: data)
    }

}

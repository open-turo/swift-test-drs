//
// Created on 4/30/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

@testable import ExampleClient
import TestDRS
import XCTest

final class WeatherServiceTests: XCTestCase {

    func testFetchingWeather() throws {
        // Using protocol-based mocks
        let networkClient = MockNetworkClientProtocol()
        let dataParser = MockDataParserProtocol()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)

        let data = try XCTUnwrap("Hello World".data(using: .utf8))
        let expectedURL = try XCTUnwrap(URL(string: "https://api.weather.com/v1/location/charleston/forecast/daily/5day.json"))

        #stub(networkClient.get(url:), returning: data)
        #stub(dataParser.parse(_:), returning: Weather(temperature: 72, description: "Sunny"))

        let weather = try weatherService.fetchWeather(for: "charleston")

        XCTAssertEqual(weather.temperature, 72)
        XCTAssertEqual(weather.description, "Sunny")

        // TODO: Use assert macro
        networkClient.assertWasCalled(networkClient.get(url:), withSignature: "get(url:)", expectedInput: expectedURL)
            .exactlyOnce()
        // TODO: Use assert macro
        dataParser.assertWasCalled(dataParser.parse(_:), withSignature: "parse(_:)", expectedInput: data, returning: Weather.self)
            .exactlyOnce()
    }

    func testFetchingWeather_WithNetworkClientError() throws {
        // Using struct-based mocks
        let networkClient = MockNetworkClientStruct()
        let dataParser = MockDataParserStruct()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)

        #stub(networkClient.get(url:), throwing: NetworkClientError.serverError)
        #stub(dataParser.parse(_:), returning: Weather(temperature: 72, description: "Sunny"))

        do {
            _ = try weatherService.fetchWeather(for: "charleston")
            XCTFail("Expected a NetworkClientError")
        } catch let networkClientError as NetworkClientError {
            XCTAssertEqual(networkClientError, .serverError)
        } catch {
            XCTFail("Expected a NetworkClientError")
        }

        // TODO: Use assert macro
        dataParser.assertWasNotCalled(dataParser.parse(_:), withSignature: "parse(_:)", returning: Weather.self)
    }

    func testFetchingWeather_WithDataParserError() throws {
        // Using class-based mocks
        let networkClient = MockNetworkClientClass()
        let dataParser = MockDataParserClass()
        let weatherService = WeatherServiceStruct(networkClient: networkClient, dataParser: dataParser)

        let data = try XCTUnwrap("Hello World".data(using: .utf8))

        #stub(networkClient.get(url:), returning: data)
        #stub(dataParser.parse(_:), using: { _ -> Weather in
            throw DataParsingError.errorParsingData
        })

        do {
            _ = try weatherService.fetchWeather(for: "charleston")
            XCTFail("Expected a DataParsingError")
        } catch let networkClientError as DataParsingError {
            XCTAssertEqual(networkClientError, .errorParsingData)
        } catch {
            XCTFail("Expected a DataParsingError")
        }
    }

}

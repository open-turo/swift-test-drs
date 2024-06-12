//
// Created on 5/3/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) throws -> Weather
}

struct WeatherServiceStruct: WeatherServiceProtocol {
    let networkClient: NetworkClientProtocol
    let dataParser: DataParserProtocol

    func fetchWeather(for city: String) throws -> Weather {
        let url = URL(string: "https://api.weather.com/v1/location/\(city)/forecast/daily/5day.json")!
        let data = try networkClient.get(url: url)
        let weather: Weather = try dataParser.parse(data)
        return weather
    }
}

//
//  WeatherService.swift
//  MyWeather
//
//  Created by Kelvin Lee on 12/8/18.
//  Copyright © 2018 Kelvin Lee. All rights reserved.
//
import Moya
import PromiseKit

class WeatherService {
    static let shared = WeatherService()

    func searchWeatherForCity(city: String, units: String = "") -> Promise<Weather> {
        return Promise { seal in
            let provider = MoyaProvider<APIService>()
            provider.request(.searchWeatherForCity(query: city, units: units), completion: { (result) in
                debugPrint("response:\(result.result)")
                switch result {
                case let .success(response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        
                        guard let weatherJson = try filteredResponse.mapJSON() as? [String: Any] else {
                            return
                        }
                        debugPrint("weatherJson:\(weatherJson)")
                        guard let name = weatherJson["name"] as? String else {
                            return
                        }
                        debugPrint("name:\(name)")
                        guard let main = weatherJson["main"] as? [String: Any] else {
                            return
                        }
                        debugPrint("main:\(main)")
                        guard let temperature = main["temp"] as? Double, let pressure = main["pressure"] as? Double, let humidity = main["humidity"] as? Double else {
                            return
                        }
                        debugPrint("temperature:\(temperature), pressure:\(pressure), humidity:\(humidity)")
                        let weather = Weather(name: name, temperature: temperature, pressure: pressure, humidity: humidity)
                        
                        seal.fulfill(weather)
                    }
                    catch let error {
                        seal.reject(error)
                    }
                case let .failure(error):
                    seal.reject(error)
                    break
                }
            })
        }
    }
}

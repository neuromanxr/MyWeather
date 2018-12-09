//
//  APIService.swift
//  MyWeather
//
//  Created by Kelvin Lee on 12/8/18.
//  Copyright © 2018 Kelvin Lee. All rights reserved.
//

import Moya

enum APIService {
    case searchWeatherForCity(query: String, units: String)
}

extension APIService: TargetType {
    
    var headers: [String : String]? {
        return nil
    }
    
    static let apiKey = "5398f72783d5d6b005dee6e449a27bd2"
    static let baseURLPath = "https://api.openweathermap.org"
    
    var baseURL: URL { return URL(string: APIService.baseURLPath)! }
    
    var path: String {
        switch self {
        case .searchWeatherForCity(_, _):
            return "/data/2.5/weather"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchWeatherForCity:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        
        case let .searchWeatherForCity(query, units):  // Always sends parameters in URL, regardless of which HTTP method is used
            return .requestParameters(parameters: ["q": query, "APPID": APIService.apiKey, "units": units], encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .searchWeatherForCity:
            return "Half measures are as bad as nothing at all.".utf8Encoded
        }
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

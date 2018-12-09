//
//  Weather.swift
//  MyWeather
//
//  Created by Kelvin Lee on 12/8/18.
//  Copyright © 2018 Kelvin Lee. All rights reserved.
//

struct Weather {
    var name: String
    var temperature: Double
    var pressure: Double
    var humidity: Double

    init(name: String, temperature: Double, pressure: Double, humidity: Double) {
        self.name = name
        self.temperature = temperature
        self.pressure = pressure
        self.humidity = humidity
    }
}

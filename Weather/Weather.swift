//
//  Weather.swift
//  Weather
//
//  Created by Trevor Harmon on 11/19/17.
//  Copyright © 2017 Trevor Harmon. All rights reserved.
//

import Foundation

class Weather {

    struct Conditions: Codable {
        var weather: [WeatherData]
        var name: String
        var main: MainData

        struct WeatherData: Codable {
            var description: String
            var icon: String
        }
        
        struct MainData: Codable {
            var temp: Float
        }
    }
    
    enum WeatherError: Error {
        case serialization(reason: String)
    }
    
    static func forCity(city: String, completion: @escaping (_ error: Error?, _ conditions: Conditions?) -> Void) {
        let session = URLSession.shared
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=\(APPID)&units=metric")!
        
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(error, nil)
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            
            guard httpResponse.statusCode == 200 else {
                 completion(WeatherError.serialization(reason: "Bad status code from service: \(httpResponse.statusCode)"), nil)
                return
            }
            
            guard let responseData = data else {
                completion(WeatherError.serialization(reason: "No data in response"), nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let conditions = try decoder.decode(Conditions.self, from: responseData)
                completion(nil, conditions)
            } catch {
                completion(error, nil)
            }
        }
        task.resume()
    }
    
    private static let APPID = "672a0cfdaa8f05a5b4db3606420b8e36"
}

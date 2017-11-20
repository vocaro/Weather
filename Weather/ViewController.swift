//
//  ViewController.swift
//  Weather
//
//  Created by Trevor Harmon on 11/19/17.
//  Copyright © 2017 Trevor Harmon. All rights reserved.
//

import UIKit

let LAST_SEARCH_KEY = "LastSearch"

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var cityName: UILabel!
    @IBOutlet private weak var temperature: UILabel!
    @IBOutlet private weak var weatherDescription: UILabel!
    @IBOutlet private weak var weatherIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityName.text = nil
        temperature.text = nil
        weatherDescription.text = nil
        
        guard let lastSearch = UserDefaults.standard.string(forKey: LAST_SEARCH_KEY) else {
            return
        }
        
        search(city: lastSearch)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text else {
            return
        }
        
        search(city: city)
    }
    
    private func search(city: String) {
        Weather.forCity(city: city) { (error: Error?, conditions: Weather.Conditions?) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showError(title: "Error", message: error.localizedDescription)
                }
                return
            }
            
            guard let conditions = conditions else {
                return
            }
            
            UserDefaults.standard.set(city, forKey: LAST_SEARCH_KEY)
            
            DispatchQueue.main.async {
                self.cityName.text = conditions.name
                self.temperature.text = "\(conditions.main.temp) ºC"
                self.weatherDescription.text = conditions.weather.first!.description
                self.weatherIcon.image(fromUrl: "http://openweathermap.org/img/w/\(conditions.weather.first!.icon).png")
            }
        }
    }
    
    private func showError(title: String, message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

// Source: http://www.andrewkouri.com/swift-3-extension-to-uiimage-to-quickly-retrieve-image-from-a-url/
extension UIImageView {
    public func image(fromUrl urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let theTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let response = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: response)
                }
            }
        }
        theTask.resume()
    }
}

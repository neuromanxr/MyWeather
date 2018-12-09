//
//  ViewController.swift
//  MyWeather
//
//  Created by Kelvin Lee on 12/8/18.
//  Copyright © 2018 Kelvin Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PromiseKit
import Charts

class ViewController: UIViewController {
    
    enum TemperatureType {
        case celsius
        case farenheit
    }
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var data: Weather?
    
    var query: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.navigationItem.title = "MyWeather"
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.tintColor = UIColor.darkGray
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "London,UK. New York. Austin."
        searchController.searchBar.delegate = self
        
        searchController.searchBar.rx.text.orEmpty
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { [unowned self] query in
                debugPrint("searching query...:\(query)")
                self.query = query
                firstly {
                    WeatherService.shared.searchWeatherForCity(city: query, units: "metric")
                }.get { data in
                    self.data = data
                }.ensure {
                    self.tableView.reloadData()
                }.catch { error in
                    debugPrint("Search error:\(error)")
                    self.data = nil
                    self.tableView.reloadData()
                }
        }).disposed(by: self.disposeBag)
    }
    
    private func handleCelsiusFarenheit(cell: WeatherCell, type: TemperatureType) {
        guard let query = self.query else {
            return
        }
        switch type {
        case .celsius:
            firstly {
                WeatherService.shared.searchWeatherForCity(city: query, units: "metric")
                }.get { data in
                    self.data = data
                }.ensure {
                    guard let data = self.data else {
                        return
                    }
                    cell.temperatureLabel.text = "Temp: \(data.temperature) C"
                    self.updateChart(cell: cell, value: data.temperature)
                }.catch { error in
                    debugPrint("Search error:\(error)")
            }
            break
        default:
            firstly {
                WeatherService.shared.searchWeatherForCity(city: query, units: "imperial")
                }.get { data in
                    self.data = data
                }.ensure {
                    guard let data = self.data else {
                        return
                    }
                    cell.temperatureLabel.text = "Temp: \(data.temperature) F"
                    self.updateChart(cell: cell, value: data.temperature)
                }.catch { error in
                    debugPrint("Search error:\(error)")
            }
            break
        }
        
    }
    
    private func updateChart(cell: WeatherCell, value: Double) {
        let yVals = BarChartDataEntry(x: 0, y: value)
        let set1: BarChartDataSet = BarChartDataSet(values: [yVals], label: "Data Set")
        cell.barChartView.data = BarChartData(dataSet: set1)
        cell.barChartView.setNeedsDisplay()
    }
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "", message: "City couldn't be found!", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alertController.addAction(alertAction)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = self.data else {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 420
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCell.reuseIdentifier, for: indexPath) as! WeatherCell
        
        cell.tempSwitch.rx.isOn.changed.debounce(0.1, scheduler: MainScheduler.instance)
            .distinctUntilChanged().asObservable()
            .subscribe(onNext:{[weak self] value in
                debugPrint("tempSwitch value:\(value)")
                if value {
                    //celsius
                    self?.handleCelsiusFarenheit(cell: cell, type: .celsius)
                } else {
                    // farenheit
                    self?.handleCelsiusFarenheit(cell: cell, type: .farenheit)
                }
            }).disposed(by: cell.disposeBag)
        
        guard let data = self.data else {
            return cell
        }
        cell.nameLabel.text = data.name
        cell.temperatureLabel.text = "Temp: \(data.temperature) C"
        cell.humidityLabel.text = "Humidity: \(data.humidity)"
        cell.pressureLabel.text = "Pressure: \(data.pressure)"
        
        self.updateChart(cell: cell, value: data.temperature)
        
        return cell
    }
}

extension ViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        print("DidDismissSearch")
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("selectedScopeButtonIndexDidChange")
    }
}


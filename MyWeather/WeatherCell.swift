//
//  WeatherCell.swift
//  MyWeather
//
//  Created by Kelvin Lee on 12/8/18.
//  Copyright © 2018 Kelvin Lee. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import Charts

class WeatherCell: UITableViewCell, NibReusable {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var tempSwitch: UISwitch!
    @IBOutlet weak var barChartView: BarChartView!
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        barChartView.delegate = self
        
        barChartView.chartDescription?.enabled = false
        barChartView.maxVisibleCount = 60
        barChartView.pinchZoomEnabled = false
        barChartView.drawBarShadowEnabled = false
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        
        barChartView.legend.enabled = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

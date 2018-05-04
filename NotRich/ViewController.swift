//
//  ViewController.swift
//  NotRich
//
//  Created by Aritro Paul on 03/05/18.
//  Copyright © 2018 NotACoder. All rights reserved.
//

import UIKit
import EFCountingLabel
import SwiftChart

struct Prices: Decodable {
    let bpi: [String: Bpi]
}

struct Bpi: Decodable {
    let code: String
    let rate_float: Double
}

class ViewController: UIViewController, ChartDelegate{
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Float, left: CGFloat) {
        //
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        //
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        //
    }
    
    @IBAction func historyTapped(_ sender: Any) {
        performSegue(withIdentifier: "History", sender: Any?.self)
    }
    @IBOutlet weak var PriceHistory: UIButton!
    @IBOutlet weak var chartView2: Chart!
    @IBOutlet weak var chartView: Chart!
    var usdprice = 0.0
    var inrprice = 0.0
    var currency = 1
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBAction func changeCurrency(_ sender: Any) {
        if currency == 1{
            currency = 0
            currencyButton.setTitle("INR", for: .normal)
            getPrices()
        }
        else if currency == 0{
            currency = 1
            currencyButton.setTitle("USD", for: .normal)
            getPrices()
        }
    }
    
    @IBOutlet weak var CurrentPrice: EFCountingLabel!
    
    func setup(){
        currencyButton.layer.cornerRadius = 8
        PriceHistory.layer.cornerRadius = 8
        cardView.layer.cornerRadius = 5
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowOpacity = 0.2
        chartView.clipsToBounds = true
        chartView2.clipsToBounds = true
        chartView2.showXLabelsAndGrid = false
        chartView.showXLabelsAndGrid = false
        
    }
    
    @objc func getPrices(){
        let urlString = "https://api.coindesk.com/v1/bpi/currentprice/INR.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            if let data = data{
                let prices = try? JSONDecoder().decode(Prices.self, from: data)
                let bpi = prices?.bpi
                self.usdprice = (bpi!["USD"]?.rate_float)!
                self.inrprice = (bpi!["INR"]?.rate_float)!
            }
            DispatchQueue.main.sync(execute:{
                if self.currency == 1{
                    self.CurrentPrice.animationDuration = 0.6
                    self.CurrentPrice.format = "%.2f"
                    self.CurrentPrice.countFromCurrentValueTo(CGFloat(self.usdprice))
                    self.updateChart()
                }
                else{
                    self.CurrentPrice.animationDuration = 0.6
                    self.CurrentPrice.format = "%.2f"
                    self.CurrentPrice.countFromCurrentValueTo(CGFloat(self.inrprice))
                    self.updateChart()
                }
            })
            }.resume()
    }
    
    func firstPlot(){
        if let datausdsaved = UserDefaults.standard.array(forKey: "usd") as? [Float]{
            datausd = datausdsaved
        }
        if let datainrsaved = UserDefaults.standard.array(forKey: "inr") as? [Float]{
            datainr = datainrsaved
        }
        let series = ChartSeries(datausd)
        series.color = ChartColors.blueColor()
        series.area = true
        chartView.removeAllSeries()
        chartView.add(series)
        let series2 = ChartSeries(datainr)
        series2.color = ChartColors.greenColor()
        series2.area = true
        chartView2.removeAllSeries()
        chartView2.add(series2)
    }
    
    var datausd: [Float] = [9000.00]
    var datainr: [Float] = [643000.00]
    @objc func updateChart(){
        let priceGraphusd = UserDefaults.standard
        let priceGraphinr = UserDefaults.standard
        if let datausdsaved = UserDefaults.standard.array(forKey: "usd") as? [Float]{
            datausd = datausdsaved
        }
        if let datainrsaved = UserDefaults.standard.array(forKey: "inr") as? [Float]{
            datainr = datainrsaved
        }
            if Float(usdprice) == datausd[datausd.count-1]{}
            else{
                if datausd.count > 20{
                    datausd.remove(at: 0)}
                datausd.append(Float(usdprice))
                print(usdprice)
                print(datausd)
                let series = ChartSeries(datausd)
                series.color = ChartColors.blueColor()
                series.area = true
                chartView.removeAllSeries()
                chartView.add(series)
                priceGraphusd.set(datausd, forKey: "usd")
            }
            if Float(inrprice) == datainr[datainr.count-1]{}
            else{
                if datainr.count > 20{
                    datainr.remove(at: 0)}
                datainr.append(Float(inrprice))
                print(inrprice)
                print(datainr)
                let series2 = ChartSeries(datainr)
                series2.color = ChartColors.greenColor()
                series2.area = true
                chartView2.removeAllSeries()
                chartView2.add(series2)
                priceGraphinr.set(datainr, forKey: "inr")
            }
        if currency == 1{
            chartView2.alpha = 0
            chartView.alpha = 1
        }
        else{
            chartView.alpha = 0
            chartView2.alpha = 1
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPrices()
        setup()
        firstPlot()
        chartView.delegate = self
        chartView2.alpha = 0
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getPrices), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateChart), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


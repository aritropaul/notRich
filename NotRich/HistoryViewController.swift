//
//  HistoryViewController.swift
//  NotRich
//
//  Created by Aritro Paul on 03/05/18.
//  Copyright © 2018 NotACoder. All rights reserved.
//

import UIKit
import SwiftChart

struct priceHistory: Decodable {
    let bpi: [String: Double]
}


class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var date1: UILabel!
    @IBOutlet weak var date2: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chartView: Chart!
    @IBAction func backTapped(_ sender: Any) {
        performSegue(withIdentifier: "main", sender: Any?.self)
    }
    
    var priceList: [String:Double] = [:]
    var datacur:[Float] = []
    func setup(){
        backButton.layer.cornerRadius = 8
        chartView.showXLabelsAndGrid = false
        
    }
    
    func getHistory(){
        let urlString = "https://api.coindesk.com/v1/bpi/historical/close.json?currency=USD"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            if let data = data{
                
                let history = try? JSONDecoder().decode(priceHistory.self, from: data)
                self.priceList = (history?.bpi)!
            }
             DispatchQueue.main.sync(execute:{
                let sortedKeys = self.priceList.keys.sorted()
                self.date1.text = sortedKeys[0]
                self.date2.text = sortedKeys[sortedKeys.count-1]
                let sortedArr = self.priceList.sorted(by: { $0.0 < $1.0 })
                for item in sortedArr{
                    self.datacur.append(Float(item.value))
                }
                let series = ChartSeries(self.datacur)
                series.color = ChartColors.blueColor()
                series.area = true
                self.chartView.removeAllSeries()
                self.chartView.add(series)
                self.tableView.reloadData()
             })
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setup()
        getHistory()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // number of rows in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.priceList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell2") as! PriceTableViewCell
        
        // set the text from the data model
        let sortedKeys = self.priceList.keys.sorted()
        cell.dateLabel.text = sortedKeys[indexPath.row]
        if let value = priceList[sortedKeys[indexPath.row]] {
            cell.priceLabel.text = String(value)
        }
        
        return cell
    }

}

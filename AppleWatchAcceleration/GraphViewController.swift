//
//  GraphViewController.swift
//  AppleWatchAcceleration
//
//  Created by フジタケンシン on 2021/05/04.
//

import UIKit
import Charts
import Foundation
import PKHUD

class GraphViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var detailButton: UIButton!
    
    var userDefault = UserDefaults.standard
    var dateString: String = ""
    var accelerationArray: [[Double]] = []
    var interval: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress)
        navigationItem.title = dateString
        if let tmp = userDefault.object(forKey: dateString) as? [[Double]] {
            accelerationArray = tmp
            print(accelerationArray)
            interval = Double(dateString.components(separatedBy: " ")[2])!
            textView.text = "startDate: \(dateString.components(separatedBy: " ")[0])\n"
            textView.text += "startTime: \(dateString.components(separatedBy: " ")[1])\n"
            textView.text += "interval: \(interval)\n\n"
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawLineChart()
        HUD.hide()
    }
    
    func drawLineChart() {
        // DataEntry作成
        var entryArray: [[ChartDataEntry]] = []
        for i in 0...2 {
            entryArray.append([])
            for (j, acceleration) in accelerationArray[i].enumerated() {
                entryArray[i].append(ChartDataEntry(x: Double(j) * interval, y: acceleration))
            }
        }
        
        // DetaSet作成
        let dataSetX = LineChartDataSet(entries: entryArray[0], label: "X")
        dataSetX.colors = [.init(ciColor: .red)]
        let dataSetY = LineChartDataSet(entries: entryArray[1], label: "Y")
        dataSetY.colors = [.init(ciColor: .green)]
        let dataSetZ = LineChartDataSet(entries: entryArray[2], label: "Z")
        dataSetZ.colors = [.init(ciColor: .blue)]
        var dataSets: [LineChartDataSet] = []
        dataSets.append(dataSetX)
        dataSets.append(dataSetY)
        dataSets.append(dataSetZ)
        for dataSet in dataSets {
            dataSet.drawCirclesEnabled = false
            dataSet.drawValuesEnabled = false
        }
        
        // Data作成
        let data = LineChartData(dataSets: dataSets)
        // Dataの設定いろいろ
        data.highlightEnabled = false
        lineChartView.data = data
        lineChartView.xAxis.drawGridLinesEnabled = false
    }

    @IBAction func showDetail(_ sender: Any) {
        present(UIAlertController(title: "表示中", message: "しばらくお待ちください", preferredStyle: .alert), animated: true) {
            self.detailButton.isHidden = true
            var xyzString = ""
            for (xyz, dataDoubleArray) in self.accelerationArray.enumerated() {
                switch xyz {
                case 0:
                    xyzString = "X"
                case 1:
                    xyzString = "Y"
                case 2:
                    xyzString = "Z"
                default:
                    xyzString = "不明"
                }
                self.textView.text += "\(xyzString)\n"
                for (i, dataDouble) in dataDoubleArray.enumerated() {
                    self.textView.text += "\(i): \(dataDouble)\n"
                }
                self.textView.text += "\n"
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

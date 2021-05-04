//
//  ViewController.swift
//  AppleWatchAcceleration
//
//  Created by フジタケンシン on 2021/04/30.
//

import UIKit
import WatchConnectivity
import PKHUD
import Charts

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    var userDefault = UserDefaults.standard
    var dateString: String = ""
    var accelerationArray: [[Double]] = []
    var interval: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // AppleWatchと通信する(WatchConnectivity)準備
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        // userDefault全削除
//        if let dates = userDefault.object(forKey: "DATE_ARRAY") as? [String] {
//            for date in dates {
//                userDefault.removeObject(forKey: date)
//            }
//        }
//        userDefault.removeObject(forKey: "DATE_ARRAY")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS: Activation did complete")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS: Session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iOS: Session did deactivate")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("iOS: Did receive user info")
        
        DispatchQueue.main.async {
            HUD.show(.progress)
            if let sendData: [String : [[Double]]] = userInfo["SEND_DATA"] as? [String : [[Double]]] {
                DispatchQueue.main.async {
                    for key in sendData.keys {
                        self.dateString = key
                        self.interval = Double(self.dateString.components(separatedBy: " ")[2])!
                        if let tmp = sendData[self.dateString] {
                            self.accelerationArray = tmp
                            var dateArray: [String] = []
                            if let savedDate = self.userDefault.object(forKey: "DATE_ARRAY") as? [String]{
                                dateArray = savedDate
                            }
                            dateArray.append(self.dateString)
                            self.userDefault.setValue(dateArray, forKey: "DATE_ARRAY")
                            self.userDefault.setValue(self.accelerationArray, forKey: self.dateString)
                            self.textView.text = "startDate: \(self.dateString.components(separatedBy: " ")[0])\n"
                            self.textView.text += "startTime: \(self.dateString.components(separatedBy: " ")[1])\n"
                            self.textView.text += "interval: \(self.interval)\n\n"
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
                        }
                    }
                    self.drawLineChart()
                }
                WCSession.default.transferUserInfo(["FINISH" : true])
            }
            
            HUD.hide()
        }
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
}


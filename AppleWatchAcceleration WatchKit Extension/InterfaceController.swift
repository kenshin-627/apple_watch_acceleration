//
//  InterfaceController.swift
//  AppleWatchAcceleration WatchKit Extension
//
//  Created by フジタケンシン on 2021/04/30.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var acceleration: WKInterfaceLabel!
    @IBOutlet weak var xAcceleration: WKInterfaceLabel!
    @IBOutlet weak var yAcceleration: WKInterfaceLabel!
    @IBOutlet weak var zAcceleration: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var stopButton: WKInterfaceButton!
    
    let motionManager = CMMotionManager()
    var xAccelerationArray: [Double] = []
    var yAccelerationArray: [Double] = []
    var zAccelerationArray: [Double] = []
    var dataArray: [[Double]] = []
    var dateString: String = ""
    var updateInterval: Double = 0.1
    
    override func awake(withContext context: Any?) {
        print("WatchOS: Awake")
        
        // iPhoneと通信する(WatchConnectivity)準備
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        stopButton.setEnabled(false)
        // 動作の更新間隔
        motionManager.deviceMotionUpdateInterval = updateInterval
    }
    
    override func willActivate() {
        print("WatchOS: Will activate")
    }
    
    override func didDeactivate() {
        print("WatchOS: Did deactivate")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WatchOS: WatchConnectivityのセッション準備完了")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("WatchOS: Did receive user info")
        
        if userInfo["FINISH"] as? Bool ?? false {
            dataArray.removeAll()
            var actions: [WKAlertAction] = []
            
            let okAction: WKAlertAction = WKAlertAction(title: "OK", style: .default) {
                self.startButton.setEnabled(true)
                self.startButton.setTitle("START")
                self.dismiss()
            }
            
            actions.append(okAction)
            presentAlert(withTitle: "完了", message: "データの送信が完了しました", preferredStyle: .alert, actions: actions)
        }
        
    }
    
    @IBAction func startAction() {
        
        if motionManager.isDeviceMotionAvailable {
            
            let handler: CMDeviceMotionHandler = {(motion: CMDeviceMotion?, error: Error?) -> Void in
                // ラベルの更新
                self.xAcceleration.setText(String(format: "X: %2f", motion!.userAcceleration.x))
                self.yAcceleration.setText(String(format: "Y: %2f", motion!.userAcceleration.y))
                self.zAcceleration.setText(String(format: "Z: %2f", motion!.userAcceleration.z))
                // 加速度の記録
                self.xAccelerationArray.append(motion!.userAcceleration.x)
                self.yAccelerationArray.append(motion!.userAcceleration.y)
                self.zAccelerationArray.append(motion!.userAcceleration.z)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.dateFormat = "yyyy/MM/dd HH/mm/ss"
            dateString = dateFormatter.string(from: Date())
            startButton.setTitle(dateString)
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: handler)
            startButton.setEnabled(false)
            stopButton.setEnabled(true)
        } else {
            self.xAcceleration.setText("利用不可")
            self.yAcceleration.setText("利用不可")
            self.zAcceleration.setText("利用不可")
        }
        
    }
    
    @IBAction func stopAction() {
        motionManager.stopDeviceMotionUpdates()
        stopButton.setEnabled(false)
        var actions: [WKAlertAction] = []
        
        let okAction = WKAlertAction(title: "送信", style: .default) {
            // 記録した加速度をまとめる
            self.dateString += " \(self.updateInterval)"
            self.dataArray.append(self.xAccelerationArray)
            self.dataArray.append(self.yAccelerationArray)
            self.dataArray.append(self.zAccelerationArray)
            let sendData: [String : [[Double]]] = [self.dateString : self.dataArray]
            
            // iPhoneにデータを送信
            if WCSession.default.isReachable {
                WCSession.default.transferUserInfo(["SEND_DATA" : sendData])
                // 加速度のデータを消去
                self.xAccelerationArray.removeAll()
                self.yAccelerationArray.removeAll()
                self.zAccelerationArray.removeAll()
            }
            
            self.dismiss()
        }
        
        let cancelAction = WKAlertAction(title: "データを破棄", style: .cancel) {
            // 加速度のデータを消去
            self.xAccelerationArray.removeAll()
            self.yAccelerationArray.removeAll()
            self.zAccelerationArray.removeAll()
            self.dataArray.removeAll()
            self.startButton.setEnabled(true)
            self.startButton.setTitle("START")
            self.stopButton.setTitle("キャンセル")
        }
        
        actions.append(okAction)
        actions.append(cancelAction)
        presentAlert(withTitle: "確認", message: "iPhoneへデータを送信します", preferredStyle: .alert, actions: actions)
        xAcceleration.setText("X:")
        yAcceleration.setText("Y:")
        zAcceleration.setText("Z:")
    }
    
}

//
//  ViewController.swift
//  AppleWatchAcceleration
//
//  Created by フジタケンシン on 2021/04/30.
//

import UIKit
import WatchConnectivity
import PKHUD

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    var userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // AppleWatchと通信する(WatchConnectivity)準備
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
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
                        var dateArray: [String] = []
                        if let savedDate = self.userDefault.object(forKey: "DATE_ARRAY") as? [String]{
                            dateArray = savedDate
                        }
                        dateArray.append(key)
                        self.userDefault.setValue(dateArray, forKey: "DATE_ARRAY")
                        self.userDefault.setValue(sendData[key], forKey: key)
                        self.textView.text = "start_interval: \(key)\n\n"
                        if let sendDoubleArray = sendData[key] {
                            var xyzString = ""
                            for (xyz, dataDoubleArray) in sendDoubleArray.enumerated() {
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
                }
                WCSession.default.transferUserInfo(["FINISH" : true])
            }
            
            HUD.hide()
        }
        
    }
    
}


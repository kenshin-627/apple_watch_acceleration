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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            if let dataArray: [[Double]] = userInfo["DATA_ARRAY"] as? [[Double]] {
                print(dataArray)
                for (xyz, data) in dataArray.enumerated() {
                    var xyzStr = ""
                    switch xyz {
                    case 0:
                        xyzStr = "X"
                    case 1:
                        xyzStr = "Y"
                    case 2:
                        xyzStr = "Z"
                    default:
                        xyzStr = "不明"
                    }
                    self.textView.text += "\(xyzStr)\n"
                    for (i, d) in data.enumerated() {
                        self.textView.text += "\(i): \(d)\n"
                    }
                    self.textView.text += "\n\n"
                }
                WCSession.default.transferUserInfo(["FINISH" : true])
            }
            HUD.hide()
        }
    }
    
    
}


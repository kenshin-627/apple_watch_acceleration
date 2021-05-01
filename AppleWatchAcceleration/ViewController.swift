//
//  ViewController.swift
//  AppleWatchAcceleration
//
//  Created by フジタケンシン on 2021/04/30.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var xRotationLabel: UILabel!
    @IBOutlet weak var yRotationLabel: UILabel!
    @IBOutlet weak var zRotationLabel: UILabel!
    @IBOutlet weak var xAccelerationLabel: UILabel!
    @IBOutlet weak var yAccelerationLabel: UILabel!
    @IBOutlet weak var zAccelerationLabel: UILabel!
    
    var dataArray: [Double] = []
    
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
            if let xRotationDouble = userInfo["xRotation"] as? Double {
                self.xRotationLabel.text = String(format: "X: %2f", xRotationDouble)
            }
            if let yRotationDouble = userInfo["yRotation"] as? Double {
                self.yRotationLabel.text = String(format: "Y: %2f", yRotationDouble)
            }
            if let zRotationDouble = userInfo["zRotation"] as? Double {
                self.zRotationLabel.text = String(format: "Z: %2f", zRotationDouble)
            }
            if let xAccelerationDouble = userInfo["xAcceleration"] as? Double {
                self.xAccelerationLabel.text = String(format: "X: %2f", xAccelerationDouble)
            }
            if let yAccelerationDouble = userInfo["yAcceleration"] as? Double {
                self.yAccelerationLabel.text = String(format: "Y: %2f", yAccelerationDouble)
            }
            if let zAccelerationDouble = userInfo["zAcceleration"] as? Double {
                self.zAccelerationLabel.text = String(format: "Z: %2f", zAccelerationDouble)
            }
        }
    }
    
    
}


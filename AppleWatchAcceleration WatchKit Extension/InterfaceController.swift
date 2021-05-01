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
    
    @IBOutlet weak var rotation: WKInterfaceLabel!
    @IBOutlet weak var xRotation: WKInterfaceLabel!
    @IBOutlet weak var yRotation: WKInterfaceLabel!
    @IBOutlet weak var zRotation: WKInterfaceLabel!
    @IBOutlet weak var acceleration: WKInterfaceLabel!
    @IBOutlet weak var xAcceleration: WKInterfaceLabel!
    @IBOutlet weak var yAcceleration: WKInterfaceLabel!
    @IBOutlet weak var zAcceleration: WKInterfaceLabel!
    
    let motionManager = CMMotionManager()
    
    override func awake(withContext context: Any?) {
        print("WatchOS: Awake")
        // iPhoneと通信する(WatchConnectivity)準備
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        // 動作の更新間隔
        motionManager.deviceMotionUpdateInterval = 1
    }
    
    override func willActivate() {
        print("WatchOS: Will activate")
        if motionManager.isDeviceMotionAvailable {
            let handler: CMDeviceMotionHandler = {(motion: CMDeviceMotion?, error: Error?) -> Void in
                // ラベルの更新
                self.xRotation.setText(String(format: "X: %2f", motion!.rotationRate.x))
                self.yRotation.setText(String(format: "Y: %2f", motion!.rotationRate.y))
                self.zRotation.setText(String(format: "Z: %2f", motion!.rotationRate.z))
                self.xAcceleration.setText(String(format: "X: %2f", motion!.userAcceleration.x))
                self.yAcceleration.setText(String(format: "Y: %2f", motion!.userAcceleration.y))
                self.zAcceleration.setText(String(format: "Z: %2f", motion!.userAcceleration.z))
                
                // iPhoneに回転率と加速度を送信
                if WCSession.default.isReachable {
                    WCSession.default.transferUserInfo(["xRotation" : motion!.rotationRate.x])
                    WCSession.default.transferUserInfo(["yRotation" : motion!.rotationRate.y])
                    WCSession.default.transferUserInfo(["zRotation" : motion!.rotationRate.z])
                    WCSession.default.transferUserInfo(["xAcceleration" : motion!.userAcceleration.x])
                    WCSession.default.transferUserInfo(["yAcceleration" : motion!.userAcceleration.y])
                    WCSession.default.transferUserInfo(["zAcceleration" : motion!.userAcceleration.z])
                }
            }
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: handler)
        } else {
            self.xRotation.setText("利用不可")
            self.yRotation.setText("利用不可")
            self.zRotation.setText("利用不可")
            self.xAcceleration.setText("利用不可")
            self.yAcceleration.setText("利用不可")
            self.zAcceleration.setText("利用不可")
        }
    }
    
    override func didDeactivate() {
        print("WatchOS: Did deactivate")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WatchOS: WatchConnectivityのセッション準備完了")
    }
    
}

//
//  GraphViewController.swift
//  AppleWatchAcceleration
//
//  Created by フジタケンシン on 2021/05/04.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var userDefault = UserDefaults.standard
    var dateString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tmp = userDefault.object(forKey: dateString) as? [[Double]] {
            textView.text = "start_interval: \(dateString)\n\n"
            var xyzString = ""
            for (xyz, dataDoubleArray) in tmp.enumerated() {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  DataViewController.swift
//  AppleWatchAcceleration
//
//  Created by フジタケンシン on 2021/05/04.
//

import UIKit

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dataTableView: UITableView!
    
    let userDefault = UserDefaults.standard
    var dates: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dataTableView.delegate = self
        dataTableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        if let dateArray = userDefault.object(forKey: "DATE_ARRAY") as? [String] {
            dates = dateArray
            num = dates.count
        }
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        let dateLabel = cell.viewWithTag(-1) as! UILabel
        dateLabel.text = dates[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let graphVC = storyboard?.instantiateViewController(withIdentifier: "Graph") as! GraphViewController
        graphVC.dateString = dates[indexPath.row]
        navigationController?.pushViewController(graphVC, animated: true)
    }
    
    @IBAction func trashAction(_ sender: UIButton) {
        let index = dataTableView.indexPath(for: sender.superview!.superview as! UITableViewCell)!.row
        let alert = UIAlertController(title: "警告", message: "\(dates[index])を削除します", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "削除", style: .destructive) { _ in
            self.userDefault.removeObject(forKey: self.dates[index])
            if var tmp = self.userDefault.object(forKey: "DATE_ARRAY") as? [String] {
                tmp.remove(at: index)
                self.userDefault.setValue(tmp, forKey: "DATE_ARRAY")
            }
            self.dataTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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

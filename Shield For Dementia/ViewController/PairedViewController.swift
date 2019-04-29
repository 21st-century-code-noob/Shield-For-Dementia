//
//  pairedViewController.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 22/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class PairedViewController: UIViewController {

    var status:[String]!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deletePairingButton: UIButton!
    @IBOutlet weak var refreshStatusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if status[1] == "1"{
            statusLabel.text = "You have been paired with " + status[0]
        }
        else{
            statusLabel.text = "Your request has been sent to " + status[0] + ", please accept on patient app"
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func deletePairingButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Pairing", message: "Are you sure you want to delete?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Delete", style: .default, handler: { (action) -> Void in
            self.deletePairing()
        })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }
        //Add OK and Cancel button to dialog message
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deletePairing(){
        deletePairingButton.isEnabled = false
        CBToast.showToastAction()
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/friend-request/cancelconnectionfromcarer?carerId=" + username
        
        let url = URL(string: requestURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    CBToast.hiddenToastAction()
                    self.deletePairingButton.isEnabled = true
                    CBToast.showToast(message: "Error Happened", aLocationStr: "center", aShowTime: 3.0)
                }
            }
            else{
                let dataString = String(data: data!, encoding: String.Encoding.utf8)
                if dataString == "\"success!\""{
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        self.deletePairingButton.isEnabled = true
                        CBToast.showToast(message: "Pairing Canceled", aLocationStr: "center", aShowTime: 3.0)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        self.deletePairingButton.isEnabled = true
                        CBToast.showToast(message: "Error", aLocationStr: "center", aShowTime: 3.0)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    @IBAction func refreshStatusButtonPressed(_ sender: Any) {
        refreshStatusButton.isEnabled = false
        CBToast.showToastAction()
        let username = UserDefaults.standard.object(forKey: "username") as? String
        if username != nil{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/carer/checkwhethercarerhaspatient?carerId=" + username!
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
                }
                else{
                    let dataString = String(data: data!, encoding: String.Encoding.utf8)
                    DispatchQueue.main.sync{
                        if dataString != "[]"{
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                                for item in json!{
                                    if let pair = item as? [String: Any]{
                                        if pair["status"] is NSNull{
                                            self.statusLabel.text = "Your request has been sent to " + (pair["user_id"] as! String) + ", please accept on patient app"
                                            self.refreshStatusButton.isEnabled = true
                                        }
                                        else if pair["status"] as! Int == 1{
                                            self.statusLabel.text = "You have been paired with " + (pair["user_id"] as! String)
                                            self.refreshStatusButton.isEnabled = true

                                        }
                                    }
                                }
                            }
                                
                            catch{
                                print(error)
                            }
                        }
                        else {
                            self.statusLabel.text = "Your last pairing request has been canceled or rejected. Back to carer panel and pair again."
                            self.refreshStatusButton.isEnabled = true
                        }
                    }
                }
            }
            task.resume()
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

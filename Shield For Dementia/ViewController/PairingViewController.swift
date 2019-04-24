//
//  pairingViewController.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 22/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class PairingViewController: UIViewController {

    @IBOutlet weak var patientIdTF: UITextField!
    @IBOutlet weak var sendRequestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendRequestButtonPressed(_ sender: Any) {
        CBToast.showToastAction()
        sendRequestButton.isEnabled = false
        if !ValidationUtils.validateUsername(username: patientIdTF.text!){
            CBToast.showToast(message: "Please enter correct patient username", aLocationStr: "center", aShowTime: 3.0)
            sendRequestButton.isEnabled = true
            CBToast.hiddenToastAction()
        }
        else{
            let carerId = UserDefaults.standard.value(forKey: "username") as! String
            let patientId = patientIdTF.text!
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/friend-request/createnewconnectionrequest?carerId=" + carerId + "&patientId=" + patientId
            let url = URL(string: requestURL)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                let dataString = String(data: data!, encoding: String.Encoding.utf8)! + ""
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        self.sendRequestButton.isEnabled = true
                        CBToast.showToast(message: "error happened", aLocationStr: "center", aShowTime: 3.0)
                    }
                }
                else if "\"success!\"" != dataString{
                    DispatchQueue.main.sync{
                        print(dataString)
                        CBToast.hiddenToastAction()
                        self.sendRequestButton.isEnabled = true
                        CBToast.showToast(message: "The patient doesn't exist.", aLocationStr: "center", aShowTime: 3.0)
                    }
                }
                else{
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        self.sendRequestButton.isEnabled = true
                        CBToast.showToast(message: "Request sent", aLocationStr: "center", aShowTime: 3.0)
                        self.navigationController?.popViewController(animated: true)
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

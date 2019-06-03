//
//  AddReminderViewController.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 7/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController {
    @IBOutlet weak var medicineNameTF: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var ringingTimePicker: UIDatePicker!
    @IBOutlet weak var lastDayTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //handles the button behaviour
    @IBAction func addReminderPressed(_ sender: Any) {
        CBToast.showToastAction()
        if !ValidationUtils.drugNameValidate(name: medicineNameTF.text!){
            CBToast.hiddenToastAction()
            displayAlert(title: "Invalid Medicine Name", message: "Medicine name should only contain letters and numbers and cannot be empty.")
        }
        else if !ValidationUtils.lastDaysValidate(days: lastDayTF.text!){
            CBToast.hiddenToastAction()
            displayAlert(title: "Invalid Lasting Day", message: "Lasting day should only contain numbers and cannot be empty")
        }
        else{
            let medicineName = medicineNameTF.text!.replacingOccurrences(of: " ", with: "+")
            let lastDays = Int(lastDayTF.text!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let startDate = dateFormatter.string(from: startDatePicker.date)
            dateFormatter.dateFormat = "HH:mm"
            let notifyTime = dateFormatter.string(from: ringingTimePicker.date)
            let patientId = UserDefaults.standard.object(forKey: "patientId") as! String
            var requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/reminder/addnewreminder?patientId=" + patientId + "&time="
            requestURL = requestURL + notifyTime + "&drugName="
            requestURL = requestURL + medicineName + "&startDate="
            requestURL = requestURL + startDate + "&lasts=" + String(describing: lastDays!)
            var urlRequest = URLRequest(url: URL(string: requestURL)!)
            urlRequest.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: urlRequest){ data, response, error in
                let dataString = String(data: data!, encoding: String.Encoding.utf8)! + ""
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        self.displayAlert(title: "Error", message: "An error occured. Please try later.")
                    }
                }
                else if "\"success!\"" != dataString{
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        print(dataString)
                        self.displayAlert(title: "Error", message: "Database error.")
                    }
                }
                else{
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            task.resume()
        }
    }
    
    //display alarm with only ok button
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }


}

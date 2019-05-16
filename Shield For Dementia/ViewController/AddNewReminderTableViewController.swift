//
//  AddNewReminderTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 17/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class AddNewReminderTableViewController: UITableViewController {

    @IBOutlet weak var medicineNameTF: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var ringingTimePicker: UIDatePicker!
    @IBOutlet weak var lastDayTF: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addReminderButtonPressed(_ sender: Any) {
        CBToast.showToastAction()
        addButton.isEnabled = false
        if !ValidationUtils.drugNameValidate(name: medicineNameTF.text!){
            CBToast.hiddenToastAction()
            displayAlert(title: "Invalid Medicine Name", message: "Drug name can only contain numbers and letter, and cannot be empty")
            addButton.isEnabled = true
            
        }
        else if !ValidationUtils.lastDaysValidate(days: lastDayTF.text!){
            CBToast.hiddenToastAction()
            displayAlert(title: "Invalid Days", message: "Days can only contain numbers.")
            addButton.isEnabled = true
        }
        else{
            let medicineName = medicineNameTF.text!.replacingOccurrences(of: " ", with: "+").trimmingCharacters(in: .whitespacesAndNewlines)
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
                        CBToast.showToast(message: "An error happened. Please try later", aLocationStr: "center", aShowTime: 3.0)
                        self.addButton.isEnabled = true
                    }
                }
                else if "\"success!\"" != dataString{
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        print(dataString)
                        CBToast.showToast(message: "Database Error", aLocationStr: "center", aShowTime: 3.0)
                        self.addButton.isEnabled = true
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
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }

}

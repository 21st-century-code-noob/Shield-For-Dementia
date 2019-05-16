//
//  ReminderTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 5/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class ReminderTableViewController: UITableViewController {
    var reminders: [Reminder] = []
    var canRefresh: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
        var items = [UIBarButtonItem]()
        items.append( UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed)))
        items.append( UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil))
        items.append( UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTable)))
        items[1].width = 15
        self.toolbarItems = items
        
        retrieveReminderData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    @objc func addButtonPressed(){
        self.performSegue(withIdentifier: "addNewReminderSegue", sender: self)
    }
    
    @objc func refreshTable(){
        if canRefresh{
            retrieveReminderData()
            canRefresh = false
            //timer to avoid frequent data request
            Timer.scheduledTimer(timeInterval:3, target: self, selector: #selector(setCanRefresh), userInfo: nil, repeats: false)
        }
    }
    
    @objc func setCanRefresh(){
        canRefresh = true
    }
    
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return reminders.count
        }
        else{
            return 1
        }
    }

    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderTableViewCell
            cell.medicineNameLabel.text = reminders[indexPath.row].drugName
            cell.timeLabel.text = reminders[indexPath.row].reminderTime
            
            let strDate = reminders[indexPath.row].startDate
            let lastDays = reminders[indexPath.row].lastTime
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let startDate = dateFormatter.date(from: strDate)
            let endDate = Calendar.current.date(byAdding: .day, value: lastDays, to: startDate!)
            let currentDate = Date()
            
            if startDate! > currentDate{
                cell.statusLabel.text = "Not Started"
                cell.statusLabel.textColor = UIColor.blue
            }
            else if(startDate! < currentDate && endDate! > currentDate){
                cell.statusLabel.text = "In Process"
                cell.statusLabel.textColor = UIColor.green
            }
            else{
                cell.statusLabel.text = "Finished"
                cell.statusLabel.textColor = UIColor.orange
            }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalNumberCell", for: indexPath) as! ReminderNumberTableViewCell
            if reminders.count == 0{
                cell.totalNumberLabel.text = "Currently no reminders."
            }
            else if reminders.count == 1{
                cell.totalNumberLabel.text = "1 reminder in total"
            }
            else{
                cell.totalNumberLabel.text = "\(reminders.count) reminders in total"
            }
            return cell
        }
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0{
            return true
        }
        else{
            return false
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/reminder/deletereminderbyreminderid?reminderId=" + String(describing: reminders[indexPath.row].reminderId)
            var urlRequest = URLRequest(url: URL(string: requestURL)!)
            urlRequest.httpMethod = "DELETE"
            let task = URLSession.shared.dataTask(with: urlRequest){ data, response, error in
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        //dispplay alert
                    }
                }
                else{
                    let resultString = String(data: data!, encoding: String.Encoding.utf8)
                    if resultString != "\"success!\""{
                        DispatchQueue.main.sync{
                            //alert
                        }
                    }
                    else{
                        DispatchQueue.main.sync {
                            self.reminders.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                            let indexSet = IndexSet(integer: 1)
                            self.tableView.reloadSections(indexSet, with: .automatic)
                        }
                    }
                }
            }
            task.resume()
        }

    }

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

    //retrive remind data from API
    func retrieveReminderData(){
        CBToast.showToastAction()
        reminders.removeAll()
        if UserDefaults.standard.value(forKey: "patientId") != nil{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/reminder/selectreminderbypatientid?patientId=" + (UserDefaults.standard.object(forKey: "patientId") as! String)
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    CBToast.hiddenToastAction()
                    print("error occured")
                }
                else{
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                        for item in json!{
                            let reminderJson = item as? [String: Any]
                            let reminderId = reminderJson!["reminder_id"] as! Int
                            let reminderTime = reminderJson!["time"] as! String
                            let drugName = reminderJson!["drug_name"] as! String
                            let startDate = reminderJson!["dates"] as! String
                            let lastTime = reminderJson!["lasts"] as! Int
                            let reminder: Reminder = Reminder(reminderId: reminderId, reminderTime: reminderTime, drugName: drugName, startDate: startDate, lastTime: lastTime)
                            self.reminders.append(reminder)
                        }
                    }
                    catch{
                        print(error)
                    }
                    DispatchQueue.main.sync{
                        CBToast.hiddenToastAction()
                        self.tableView.reloadData()
                    }
                }
            }
            task.resume()
        }
        else{
            CBToast.hiddenToastAction()

        }
    }
}

//
//  RouteListTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 10/5/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import Firebase

class RouteCell: UITableViewCell{
    
    var patientId = UserDefaults.standard.value(forKey: "patientId") as! String
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage()
    
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var routeAvailableOrNotSwitch: UISwitch!
    
    @IBAction func routeAvailableOrNot(_ sender: UISwitch) {
        
        if(sender.isOn == true){
            print("is on")
            let routeName = routeNameLabel.text
            databaseRef.child("users").child(patientId).child("availableRoute").updateChildValues([routeName!: 1])
        }
        else{
            print("is off")
            databaseRef.child("users").child(patientId).child("availableRoute").child(routeNameLabel.text!).removeValue()

        }
    }
}

class RouteListTableViewController: UITableViewController {

    var requestId = UserDefaults.standard.value(forKey: "requestId") as! Int
    var locationList = [FencedAnnotation]()
    var routeSelected: String?
    var routeNameList: [String] = []
    var availableList: [String] = []
    
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage()
    var patientId = UserDefaults.standard.value(forKey: "patientId") as! String
    
    @IBAction func Explanation(_ sender: Any) {
        displayMessage("Safe route means the possible route between different safe zone locations. In order to use this function, there must be at least two safe zone locations.", "Information")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locationList = []
        routeSelected = ""
        routeNameList = []
        availableList.removeAll()
        
        //download safe zones information
        let requestURL = "Replace it with your API which can load safe zones for the pairing" + String(requestId)
        
        
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    //self.displayAlert(title: "Error", message: "An error occured, please try later.")
                }
            }
            else{
                
                let responseString = String(data: data!, encoding: String.Encoding.utf8)! as String
                
                DispatchQueue.main.sync{
                    
                    if responseString != "[]"{
                        
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            
                            for a in json!{
                                
                                let b = a as! NSDictionary
                                let newAnnotation = FencedAnnotation(newTitle: b.value(forKey: "locationName") as! String,newSubtitle: String(b.value(forKey: "idsafeZoneLocation") as! Int),lat: b.value(forKey: "latitude") as! Double, long: b.value(forKey: "longitude") as! Double)
                                
                                self.locationList.append(newAnnotation)
                            }
                            self.tableView.reloadData()
                            
                        }
                        catch{
                            
                        }
                    }
                }
            }
        }
        task.resume()
        
        //download available route
        databaseRef.child("users").child(patientId).child("availableRoute").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let response = snapshot.value as? NSDictionary
            if response != nil{
                self.availableList = response?.allKeys as! [String]
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func displayMessage(_ message: String,_ title: String){
        let alertController = UIAlertController(title:title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationList.count * (locationList.count - 1)/2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routecell", for: indexPath) as! RouteCell
        cell.routeAvailableOrNotSwitch.isOn = false
        var i = 1
        var number = 0
        while i < locationList.count{
            
            if(i == 1){
                number = indexPath.row + 1 - (locationList.count - i)
            }
            else{
                number = number - (locationList.count - i)
            }
            
            
            if(number < 0){
                number = number + locationList.count - i
                break
            }
            else if(number == 0){
                break
            }
            i += 1
        }
        
        
        if(number == 0){
            cell.routeNameLabel.text = locationList[i-1].title! + " <=> " + locationList[locationList.count-1].title!
            routeNameList.append(cell.routeNameLabel.text!)
        }
        else{
             cell.routeNameLabel.text = locationList[i-1].title! + " <=> " + locationList[number+i-1].title!
            routeNameList.append(cell.routeNameLabel.text!)
        }
        
        for availableName in availableList{
            if(availableName == cell.routeNameLabel.text!){
                cell.routeAvailableOrNotSwitch.isOn = true
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        routeSelected = routeNameList[indexPath.row]
        performSegue(withIdentifier: "routeDetail", sender: nil)
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "routeDetail"){
            let controller = segue.destination as! RouteDetailTableViewController
            controller.routeName = self.routeSelected
        }
    }
 

}

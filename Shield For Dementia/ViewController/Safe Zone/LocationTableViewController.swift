//
//  LocationTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 25/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
    
    var requestId = UserDefaults.standard.value(forKey: "requestId") as! Int
    var locationList = [FencedAnnotation]()
    
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
        
        //download safe zones 
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
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as UITableViewCell
        
        
        let annotation = locationList[indexPath.row]
        cell.textLabel?.text = annotation.title!
        cell.detailTextLabel?.text = "Lat: " + String(annotation.coordinate.latitude) + "; Long: " + String(annotation.coordinate.longitude)
        cell.selectionStyle = .none
        // Configure the cell...
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            
            let requestURL = "Replace it with your API which can delete a safe zone" + locationList[indexPath.row].subtitle!
            
            self.locationList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            var urlRequest = URLRequest(url: URL(string: requestURL)!)
            urlRequest.httpMethod = "DELETE"
            let task = URLSession.shared.dataTask(with: urlRequest){ data, response, error in
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        //self.displayAlert(title: "Error", message: "An error occured, please try later.")
                    }
                }
                else{
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
    
}


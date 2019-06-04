//
//  NewLocationTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 25/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit

class NewLocationTableViewController: UITableViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var familiarityPickerView: UIPickerView!
    let options = ["High", "Medium", "Low"]
    var familiarityResult = "Medium"
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        familiarityResult = options[row]
    }
    
    
    @IBAction func handleSingleTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    var friendRequestId = UserDefaults.standard.value(forKey: "requestId") as! Int
    
    var locationManger: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var locationNameErrorLabel: UILabel!
    
    @IBAction func locationNameValidation(_ sender: Any) {
        
        if(locationNameTextField.text!.count > 20 || locationNameTextField.text!.count == 0){
            locationNameErrorLabel.text = "Maxiumum number of character is 20"
        }
        else{
            locationNameErrorLabel.text = ""
        }
    }
    
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var postcodeErrorLabel: UILabel!
    
    @IBAction func postcodeValidation(_ sender: Any) {
        
        let postcode = (postcodeTextField.text! as NSString).intValue
        if(postcodeTextField.text != ""){
            if(postcode <= 0 || postcode >= 10000 || postcode < 1000){
                postcodeErrorLabel.text = "4 number only"
            }
            else{
                postcodeErrorLabel.text = ""
            }
        }
        else{
            postcodeErrorLabel.text = ""
        }
    }
    
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var latErrorLabel: UILabel!
    
    @IBAction func latValidation(_ sender: Any) {
        let lat = (latTextField.text! as NSString).doubleValue
        if(lat > 90 || lat < -90 || lat == 0){
            latErrorLabel.text = "Valid latitude range from -90 to 90"
        }
        else{
            latErrorLabel.text = ""
        }
    }
    
    @IBOutlet weak var longTextField: UITextField!
    @IBOutlet weak var longErrorLabel: UILabel!
    @IBAction func longValidation(_ sender: Any) {
        let long = (longTextField.text! as NSString).doubleValue
        if(long > 180 || long < -180 || long == 0){
            longErrorLabel.text = "Valid longitude range from -180 to 180"
        }
        else{
            longErrorLabel.text = ""
        }
    }
    
    
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        
        if currentLocation == nil{
            latTextField.text = "0.0"
            longTextField.text = "0.0"
        }
        else{
            latTextField.text = "\(currentLocation!.latitude)"
            longTextField.text = "\(currentLocation!.longitude)"
        }
        latValidation(NewLocationTableViewController.self)
        longValidation(NewLocationTableViewController.self)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc: CLLocation = locations.last!
        currentLocation = loc.coordinate
    }
    
    @IBAction func save(_ sender: Any) {
        
        if(locationNameErrorLabel.text == "" && postcodeErrorLabel.text == "" && latErrorLabel.text == "" && longErrorLabel.text == "" && locationNameTextField.text != "" && latTextField.text != "" && longTextField.text != ""){
            
            var requestURL = "Replace it with your API which can create a new safe zone"
            requestURL = requestURL + "?locationName=" + locationNameTextField.text!.trimmingCharacters(in: .whitespaces)
            requestURL = requestURL + "&latitude=" + latTextField.text!.trimmingCharacters(in: .whitespaces)
            requestURL = requestURL + "&longitude=" + longTextField.text!.trimmingCharacters(in: .whitespaces)
            requestURL = requestURL + "&friendRequestId=" + String(friendRequestId).trimmingCharacters(in: .whitespaces)
            requestURL = requestURL + "&postcode=" + postcodeTextField.text!.trimmingCharacters(in: .whitespaces)
            requestURL = requestURL + "&familiarity=" + familiarityResult
            
            requestURL = requestURL.replacingOccurrences(of: " ", with: "+")
            var urlRequest = URLRequest(url: URL(string: requestURL)!)
            urlRequest.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: urlRequest){ data, response, error in
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        //self.displayAlert(title: "Error", message: "An error occured, please try later.")
                    }
                }
                else{
                    DispatchQueue.main.sync{
                        self.locationNameTextField.text = ""
                        self.locationNameErrorLabel.text = ""
                        self.postcodeTextField.text = ""
                        self.postcodeErrorLabel.text = ""
                        self.latTextField.text = ""
                        self.latErrorLabel.text = ""
                        self.longTextField.text = ""
                        self.longErrorLabel.text = ""
                        self.familiarityResult = "Medium"
                        //self.displayMessage("Location has been saved!", "Success!")
                        CBToast.showToastAction(message: "New location has been saved!")
                        self.navigationController?.popViewController(animated: true)
                        //self.displayAlert(title: "Error", message: "An error occured, please try later.")
                    }
                    
                }
                
            }
            task.resume()
            
        }
        else{
            displayMessage("Cannot save new location, Please check your input", "Failed!")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.distanceFilter = 10
        locationManger.delegate = self
        locationManger.requestAlwaysAuthorization()
        locationManger.startUpdatingLocation()
        hideKeyboardWhenTappedAround()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //locationNameTextField.text = ""
        locationNameErrorLabel.text = ""
        //postcodeTextField.text = ""
        postcodeErrorLabel.text = ""
        //latTextField.text = ""
        latErrorLabel.text = ""
        //longTextField.text = ""
        longErrorLabel.text = ""
        familiarityPickerView.selectRow(1, inComponent: 0, animated: false)
        familiarityResult = "Medium"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    //    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    //        cell.selectionStyle = .none
    //        // Configure the cell...
    //
    //        return cell
    //    }
    
    
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
    
    
    func displayMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "custom"{
            let controller = segue.destination as! CustomViewController
            controller.latTextField = self.latTextField
            controller.longTextField = self.longTextField
        }
    }
    
    
}


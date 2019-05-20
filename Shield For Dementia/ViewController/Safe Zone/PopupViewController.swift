//
//  PopupViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 11/5/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class PopupViewController: UIViewController, SBCardPopupContent, CLLocationManagerDelegate {
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard: Bool = true
    var allowsSwipeToDismissPopupCard: Bool = true
    
    static func create() -> UIViewController{
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        
        return storyboard
    }
    
    let patientId = UserDefaults.standard.value(forKey: "patientId") as! String
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage()
    
    var routePointList = Dictionary<String, Dictionary<String, Float>>()
        //= [Int:["lat": Float, "long": Float]]
    var locationManger: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var timer = Timer()
    var timerForLabel = Timer()
    var totalTime = 0
    var numberOfPoint = -1
    
    var routeName: String?
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var startStopSaveButton: UIButton!
    
    @IBAction func startStopSaveButton(_ sender: Any) {
        switch startStopSaveButton.titleLabel?.text {
        case "Start":
            if(currentLocation == nil){
                displayMessage("Please turn on the location service", "Alert")
            }
            else{
                startStopSaveButton.setTitle("Stop", for: .normal)
                startStopSaveButton.backgroundColor = UIColor.red
                
                timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.saveRoutePoint), userInfo: nil, repeats: true)
                timerForLabel = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimeLabel), userInfo: nil, repeats: true)
            }
            break
            
        case "Stop":
            startStopSaveButton.setTitle("Save", for: .normal)
            startStopSaveButton.backgroundColor = UIColor.init(red: 240/255, green: 164/255, blue: 66/255, alpha: 1)
            timer.invalidate()
            timerForLabel.invalidate()
            
            break
            
        case "Save":
            startStopSaveButton.setTitle("Start", for: .normal)
           
            self.databaseRef.child("users").child(patientId).child("routeList").child(routeName!).removeValue()
            self.databaseRef.child("users").child(patientId).child("routeList").child(routeName!).child("pointList").updateChildValues(routePointList)
            self.databaseRef.child("users").child(patientId).child("routeList").child(routeName!).updateChildValues(["duration": totalTime])
            
            routePointList.removeAll()
            numberOfPoint = 0
            timeLabel.text = "00:00"
            displayMessage("The new route has been updated", "Success")
            break
            
        default: break
        }
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.popupViewController?.close()
    }
    
    @objc func saveRoutePoint(){
        numberOfPoint += 1
        routePointList[String(numberOfPoint)] = ["lat": Float(currentLocation!.latitude), "long": Float(currentLocation!.longitude)]
    }
    
    @objc func updateTimeLabel(){
        totalTime += 1
        let result = totalTime.quotientAndRemainder(dividingBy: 60)
        
        timeLabel.text = String(result.quotient) + ":" + String(result.remainder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.distanceFilter = 10
        locationManger.delegate = self
        locationManger.requestAlwaysAuthorization()
        locationManger.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startStopSaveButton.setTitle("Start", for: .normal)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc: CLLocation = locations.last!
        currentLocation = loc.coordinate
    }
    
    func displayMessage(_ message: String,_ title: String){
        let alertController = UIAlertController(title:title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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

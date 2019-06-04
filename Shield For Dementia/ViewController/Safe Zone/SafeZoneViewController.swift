//
//  SafeZoneViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 24/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class SafeZoneViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findPatientButton: UIButton!
    
    private let locationManager = CLLocationManager()
    var requestId = UserDefaults.standard.value(forKey: "requestId") as! Int
    var patientLocation : FencedAnnotation?
    var locationList  = [FencedAnnotation]()
    var overlayList: [MKOverlay] = []
    var geoLocationList: [CLCircularRegion] = []
    var geoLocation: CLCircularRegion?
    
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage()
    
    @IBAction func findPatientButton(_ sender: Any) {
        if(patientLocation != nil){
            focusOn(annotation: patientLocation!)
        }
        else{
            displayMessage("Patient has not started the location service, please wait.", "Alert")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        mapView.delegate = self
        
        //MKOverlayPathView
        
        
        //monitor patient's locatopm
        let patientId = UserDefaults.standard.value(forKey: "patientId") as! String
        databaseRef.child("users").child("\(patientId)").child("realTimeLocation").observe(.value, with:{(snapshot) in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
            let longitude = value.value(forKey: "longitude") as! Double
            let latitude = value.value(forKey: "latitude") as! Double
            
            if(self.patientLocation != nil){
                self.mapView.removeAnnotation(self.patientLocation!)
            }
            self.patientLocation = FencedAnnotation(newTitle: patientId,newSubtitle: "",lat: latitude, long: longitude)
            self.addAnnotation(annotation: self.patientLocation!)
        })
        
        //monitor notification
        databaseRef.child("users").child("\(patientId)").child("notificationExitRegin").observe(.value, with:{(snapshot) in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
            let locationExited = value.value(forKey: "locationExited") as! String
            let status = value.value(forKey: "notification") as! Int
            
            if(status == 1){
                self.databaseRef.child("users").child("\(patientId)").child("notificationExitRegin").updateChildValues(["notification":0])
                self.displayMessage("\(patientId) has left \(locationExited), Please check.", "Alert")

            }

        })
        
        //monitor notification
        databaseRef.child("users").child("\(patientId)").child("notificationWhenTimerIsUp").observe(.value, with:{(snapshot) in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
            
            let destination = value.value(forKey: "destination") as! String
            let status = value.value(forKey: "notification") as! Int
            let timeLimit = value.value(forKey: "time limit") as! String
            
            if(status == 1){
                if(destination == "Unknown"){
                    self.databaseRef.child("users").child("\(patientId)").child("notificationWhenTimerIsUp").updateChildValues(["notification":0])
                    self.displayMessage("\(patientId) has left the safe zone for 10 mins without setting the destination, Please check.", "Alert")
                }
                else{
                    self.databaseRef.child("users").child("\(patientId)").child("notificationWhenTimerIsUp").updateChildValues(["notification":0])
                    self.displayMessage("\(patientId) has not been in \(destination) after \(timeLimit), Please check.", "Alert")
                }
            }
        })
        
        //monitor notification
        databaseRef.child("users").child("\(patientId)").child("notificationOnOtherPlaces").observe(.value, with:{(snapshot) in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
            
            let status = value.value(forKey: "notification") as! Int
            
            if(status == 1){
                self.databaseRef.child("users").child("\(patientId)").child("notificationOnOtherPlaces").updateChildValues(["notification":0])
                self.displayMessage("\(patientId) wants to go to other places, you may need to create new safe zone locations.", "Alert")
                
            }
            
        })
        
        //monitor notification
        databaseRef.child("users").child("\(patientId)").child("notificationWhenNoRoute").observe(.value, with:{(snapshot) in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
            
            let destination = value.value(forKey: "destination") as! String
            let status = value.value(forKey: "notification") as! Int
            let start = value.value(forKey: "start") as! String
            
            if(status == 1){
                self.databaseRef.child("users").child("\(patientId)").child("notificationWhenNoRoute").updateChildValues(["notification":0])
                    self.displayMessage("\(patientId) wants to go from \(start) to \(destination), But there is no route available please check.", "Alert")
                
            }
        })
        
        //monitor notification
        databaseRef.child("users").child("\(patientId)").child("notificationWhenDeviate").observe(.value, with:{(snapshot) in
            guard let value = snapshot.value as? NSDictionary else{
                return
            }
            
            let destination = value.value(forKey: "destination") as! String
            let status = value.value(forKey: "notification") as! Int
            let start = value.value(forKey: "start") as! String
            
            if(status == 1){
                self.databaseRef.child("users").child("\(patientId)").child("notificationWhenDeviate").updateChildValues(["notification":0])
                self.displayMessage("\(patientId) wants to go from \(start) to \(destination), But he is deviating from the safe route please check.", "Alert")
                
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    func displayMessage(_ message: String,_ title: String){
        let alertController = UIAlertController(title:title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.mapView.removeOverlays(overlayList)
        overlayList = []
        self.mapView.removeAnnotations(locationList)
        locationList = []
        for geoLocation in geoLocationList{
            locationManager.stopMonitoring(for: geoLocation)
        }
        geoLocationList = []
        
        //download safe zones
        let requestURL = "Replace it with your API which can load all safe zones based on the pairing" + String(requestId)
        
        
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
                                let newAnnotation = FencedAnnotation(newTitle: b.value(forKey: "locationName") as! String,newSubtitle: b.value(forKey: "familiarity") as! String,lat: b.value(forKey: "latitude") as! Double, long: b.value(forKey: "longitude") as! Double)
                                newAnnotation.subtitle = "Familiarity: " + newAnnotation.subtitle!
                                self.addAnnotation(annotation: newAnnotation)
                                self.locationList.append(newAnnotation)
                                var geoLocation: CLCircularRegion? = CLCircularRegion(center: newAnnotation.coordinate, radius: 75, identifier: newAnnotation.title!)
                                //geoLocation!.notifyOnExit = true
                                geoLocation!.notifyOnEntry = true
                                
                                let circle: MKCircle = MKCircle.init(center: newAnnotation.coordinate, radius: 75)
                                
                                if(newAnnotation.subtitle == "Familiarity: Low"){
                                    geoLocation = CLCircularRegion(center: newAnnotation.coordinate, radius: 50, identifier: newAnnotation.title!)
                                    circle.setValue(50, forKey: "radius")
                                }
                                else if(newAnnotation.subtitle == "Familiarity: High"){
                                    geoLocation = CLCircularRegion(center: newAnnotation.coordinate, radius: 100, identifier: newAnnotation.title!)
                                    circle.setValue(100, forKey: "radius")
                                }
                                
                                self.overlayList.append(circle)
                                self.mapView.addOverlay(circle)
                                self.geoLocationList.append(geoLocation!)
                                self.locationManager.startMonitoring(for: geoLocation!)
                            }
                            self.focusOn(annotation: self.locationList[0])
                        }
                        catch{
                            
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func addAnnotation(annotation: MKAnnotation){
        self.mapView.addAnnotation(annotation)
    }
    
    func focusOn(annotation: MKAnnotation){
        self.mapView.centerCoordinate = annotation.coordinate
        self.mapView.selectAnnotation(annotation,animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(zoomRegion, animated: true)
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

extension SafeZoneViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        

        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
        circle.fillColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 0.2)
        circle.lineWidth = 1.5
        
        return circle
        
    }
    
    // Code Pro, Computer Program video, (youtube, 2018)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        }
        
        if annotation.isKind(of: MKUserLocation.self){
            return nil
        }
        //annotationView?.leftCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        
        var sizeChange : CGSize?
        let origin = CGPoint(x: 0, y: 0)
        
        var imagea : UIImage?
        let patientId = UserDefaults.standard.value(forKey: "patientId") as! String
        if annotation.title == patientId{
            
            sizeChange = CGSize(width: 50, height: 50)
            imagea = UIImage(named: "old_man")
        }
        else{
            sizeChange = CGSize(width: 30, height: 30)
            imagea = UIImage(named: "map_mark_safe_zone")
        }
        UIGraphicsBeginImageContextWithOptions(sizeChange!, false, 0.0)
        
        imagea?.draw(in: CGRect(origin: origin, size: sizeChange!))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = newImage
        annotationView?.image?.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        annotationView?.canShowCallout = true
        return annotationView
    }
}

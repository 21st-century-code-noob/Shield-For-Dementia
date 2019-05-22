//
//  HeatMapViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 30/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit

class HeatMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    
    var locationList  = [FencedAnnotation]()
    var overlayList: [MKOverlay] = []
    var geoLocationList: [CLCircularRegion] = []
    var geoLocation: CLCircularRegion?
    var locationManger: CLLocationManager = CLLocationManager()
    
    @IBAction func ShowUserLocation(_ sender: Any) {
        if(currentLocation != nil){
            let userlocation = FencedAnnotation(newTitle: "user", newSubtitle: "", lat: currentLocation!.latitude, long: currentLocation!.longitude)
            focusOn(annotation: userlocation)
        }
        else{
            displayMessage("the location service is turned off, please check.", "Alert")
        }
    }
    
    @IBAction func Explanation(_ sender: Any) {
        displayMessage("You can check the safety level for different postcode areas.", "Information")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        // Do any additional setup after loading the view.
        //download all data
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/graded-suburb"
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    self.displayMessage("An error occured, please try later.", "Error")
                }
            }
            else{
                let responseString = String(data: data!, encoding: String.Encoding.utf8)! as String
                
                
                
                DispatchQueue.main.sync{
                    
                    if responseString != "[]"{
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            
                            for a in json!{
                                var newAnnotation : FencedAnnotation?
                                let b = a as! NSDictionary
                                let graded_value = b.value(forKey: "graded_value") as! Double
                                if(graded_value > 66){
                                     newAnnotation = FencedAnnotation(newTitle: "Postcode: " +  (b.value(forKey: "postcode") as! String),newSubtitle: "Safety Level: Dangerous",lat: b.value(forKey: "latitude") as! Double, long: b.value(forKey: "longitude") as! Double)
                                }
                                else if(graded_value <= 66 && graded_value >= 33){
                                     newAnnotation = FencedAnnotation(newTitle: "Postcode: " +  (b.value(forKey: "postcode") as! String),newSubtitle: "Safety Level: Medium",lat: b.value(forKey: "latitude") as! Double, long: b.value(forKey: "longitude") as! Double)
                                }else{
                                    newAnnotation = FencedAnnotation(newTitle: "Postcode: " +  (b.value(forKey: "postcode") as! String),newSubtitle: "Safety Level: Safe",lat: b.value(forKey: "latitude") as! Double, long: b.value(forKey: "longitude") as! Double)
                                }
                               
                                
                                
                                self.addAnnotation(annotation: newAnnotation!)
                                let circle: MKCircle = MKCircle.init(center: newAnnotation!.coordinate, radius: 800)
                                circle.subtitle = String(b.value(forKey: "graded_value") as! Double)
                                self.overlayList.append(circle)
                                self.mapView.addOverlay(circle)
                                
                            }
                            
                        }
                        catch{
                            
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureLocationServices()

        let mel = FencedAnnotation(newTitle: "",newSubtitle: "",lat:-37.8136, long:144.9631)
        focusOn(annotation: mel)
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func configureLocationServices(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func addAnnotation(annotation: MKAnnotation){
        self.mapView.addAnnotation(annotation)
    }
    
    func focusOn(annotation: MKAnnotation){
        self.mapView.centerCoordinate = annotation.coordinate
        self.mapView.selectAnnotation(annotation,animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        self.mapView.setRegion(zoomRegion, animated: true)
    }
    
    func displayMessage(_ message: String,_ title: String){
        let alertController = UIAlertController(title:title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension HeatMapViewController: CLLocationManagerDelegate{
    
    //Moodle
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let latestLocation = locations.first else {return}
        currentLocation = latestLocation.coordinate
    }
}

extension HeatMapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        
        var bili = 255 - Double(overlay.subtitle!!)! * 2.55
        if(bili < 0){
            bili = 0
        }
        
        

        
        
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor(red: CGFloat(bili/255), green: CGFloat(bili/255), blue: CGFloat(bili/255), alpha: 1)
        circle.fillColor = UIColor(red: CGFloat(bili/255), green: CGFloat(bili/255), blue: CGFloat(bili/255), alpha: 0.5)
        circle.lineWidth = 2
        
        return circle
        
    }
    
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
        if annotation.title == "Patient"{
            
            sizeChange = CGSize(width: 50, height: 50)
            imagea = UIImage(named: "old_man")
        }
        else{
            sizeChange = CGSize(width: 30, height: 30)
            imagea = UIImage(named: "postcode")
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


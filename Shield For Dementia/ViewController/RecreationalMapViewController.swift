//
//  RecreationalMapViewController.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/5/11.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RecreationalMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapKit: MKMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    var locationManager = CLLocationManager()
    var yogantaichisList:[RecreationalAnnotation] = [RecreationalAnnotation]()
    var parkList:[RecreationalAnnotation] = [RecreationalAnnotation]()
    var volunteeringList:[RecreationalAnnotation] = [RecreationalAnnotation]()
    var fitnessList:[RecreationalAnnotation] = [RecreationalAnnotation]()
    var hasFocused: Bool = false
    var currentRegion:MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKit.delegate = self
        
        let titles = ["Yoga & Taichi", "Volunteering", "Fitness", "Parks"]
        let segmentControl = UISegmentedControl(items: titles)
        segmentControl.tintColor = UIColor.orange
        segmentControl.backgroundColor = UIColor.white
        segmentControl.selectedSegmentIndex = 0
        
        segmentControl.setWidth(90, forSegmentAt: 0)
        segmentControl.setWidth(90, forSegmentAt: 1)
        segmentControl.setWidth(60, forSegmentAt: 2)
        segmentControl.setWidth(60, forSegmentAt: 3)

        segmentControl.sizeToFit()
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sendActions(for: .valueChanged)
        navigationItem.titleView = segmentControl
        
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        self.mapKit.showsUserLocation = true
        loadYogaTaichiData()
    }
    
    @objc func segmentChanged(){
        let segment = self.navigationItem.titleView as? UISegmentedControl
        
        switch segment?.selectedSegmentIndex{
            case 0: loadYogaTaichiData()
            case 1: loadVolunteeringData()
            case 2: loadFitnessData()
            case 3: loadParkData()
            default: return
        }

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last{
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.currentRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            if !hasFocused{
                self.mapKit.setRegion(currentRegion!, animated: true)
                hasFocused = true
                currentLocationButton.isEnabled = true
            }
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

   
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? RecreationalAnnotation else { return nil }
        // 3
        let identifier = "annotation"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 0)
            let btn = UIButton(type: .system)
            
            btn.setTitle("Go There", for: .init())
            btn.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
            view.rightCalloutAccessoryView = btn
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let regionDistance: CLLocationDistance = 100;
        let regionSpan = MKCoordinateRegion(center: view.annotation!.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let option = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placeMark = MKPlacemark(coordinate: view.annotation!.coordinate)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = view.annotation!.title!
        mapItem.openInMaps(launchOptions: option)
        
    }
    
    func loadYogaTaichiData(){
        (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = false
        CBToast.showToastAction()
        let allAnnotations = mapKit.annotations
        mapKit.removeAnnotations(allAnnotations)
        
        if yogantaichisList.count == 0{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/yoga-taichi"
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        CBToast.showToast(message : "Error occured, please try later.", aLocationStr : "center", aShowTime : 3.0)
                    }
                }
                else{
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)! as String
                    if responseString != "[]"{
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            for a in json!{
                                let item = a as! NSDictionary
                                let yogaAnnotation = RecreationalAnnotation(newTitle: item.value(forKey: "Y_T_Name") as! String, newAddress:  item.value(forKey: "Y_T_Address") as! String, lat: item.value(forKey: "Y_T_Latitude") as! Double, long: item.value(forKey: "Y_T_Longitude") as! Double)
                                self.yogantaichisList.append(yogaAnnotation)
                                self.mapKit.addAnnotation(yogaAnnotation)
                            }
                            DispatchQueue.main.sync {
                                (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = true
                                CBToast.hiddenToastAction()
                            }
                            
                        }
                        catch{
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
        else{
            for annotation in yogantaichisList{
                mapKit.addAnnotation(annotation)
            }
            (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = true
            CBToast.hiddenToastAction()
        }
    }
    
    func loadParkData(){
        (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = false
        CBToast.showToastAction()
        
        let allAnnotations = mapKit.annotations
        mapKit.removeAnnotations(allAnnotations)
        
        if parkList.count == 0{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/parks"
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        CBToast.showToast(message : "Error occured, please try later.", aLocationStr : "center", aShowTime : 3.0)
                    }
                }
                else{
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)! as String
                    if responseString != "[]"{
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            for a in json!{
                                let item = a as! NSDictionary
                                let parkAnnotation = RecreationalAnnotation(newTitle: item.value(forKey: "P_Name") as! String, newAddress:  item.value(forKey: "P_Suburb") as! String, lat: item.value(forKey: "P_Latitude") as! Double, long: item.value(forKey: "P_Longitude") as! Double)
                                self.parkList.append(parkAnnotation)
                                self.mapKit.addAnnotation(parkAnnotation)
                            }
                            DispatchQueue.main.sync {
                                (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = true
                                CBToast.hiddenToastAction()
                            }
                        }
                        catch{
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
        else{
            for annotation in parkList{
                mapKit.addAnnotation(annotation)
            }
            (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = true
            CBToast.hiddenToastAction()
        }
    }
    
    func loadVolunteeringData(){
        (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = false
        CBToast.showToastAction()
        
        let allAnnotations = mapKit.annotations
        mapKit.removeAnnotations(allAnnotations)
        
        if volunteeringList.count == 0{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/volunteer"
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        CBToast.showToast(message : "Error occured, please try later.", aLocationStr : "center", aShowTime : 3.0)
                    }
                }
                else{
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)! as String
                    if responseString != "[]"{
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            for a in json!{
                                let item = a as! NSDictionary
                                let volunteeringAnnotation = RecreationalAnnotation(newTitle: item.value(forKey: "V_Name") as! String, newAddress:  item.value(forKey: "V_F_Address") as! String, lat: item.value(forKey: "V_Latitude") as! Double, long: item.value(forKey: "V_Longitude") as! Double)
                                self.volunteeringList.append(volunteeringAnnotation)
                                self.mapKit.addAnnotation(volunteeringAnnotation)
                            }
                            DispatchQueue.main.sync {
                                (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = true
                                CBToast.hiddenToastAction()
                            }
                        }
                        catch{
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
        else{
            for annotation in volunteeringList{
                mapKit.addAnnotation(annotation)
            }
            (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = true
            CBToast.hiddenToastAction()
        }
    }
    
    func loadFitnessData(){
        (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = false
        CBToast.showToastAction()
        
        let allAnnotations = mapKit.annotations
        mapKit.removeAnnotations(allAnnotations)
        
        if fitnessList.count == 0{
            let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/fitness"
            let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
                if error != nil{
                    print("error occured")
                    DispatchQueue.main.sync{
                        CBToast.showToast(message : "Error occured, please try later.", aLocationStr : "center", aShowTime : 3.0)
                    }
                }
                else{
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)! as String
                    if responseString != "[]"{
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            for a in json!{
                                let item = a as! NSDictionary
                                let fitnessAnnotation = RecreationalAnnotation(newTitle: item.value(forKey: "f_name") as! String, newAddress:  item.value(forKey: "f_fulladress") as! String, lat: item.value(forKey: "f_latitudes") as! Double, long: item.value(forKey: "f_longitudes") as! Double)
                                self.fitnessList.append(fitnessAnnotation)
                                self.mapKit.addAnnotation(fitnessAnnotation)
                            }
                            DispatchQueue.main.sync {
                                (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = true
                                CBToast.hiddenToastAction()
                            }
                        }
                        catch{
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
        else{
            for annotation in fitnessList{
                mapKit.addAnnotation(annotation)
            }
            (self.navigationItem.titleView as? UISegmentedControl)?.isEnabled = true
            CBToast.hiddenToastAction()
        }
    }
    @IBAction func myLocationButtonPressed(_ sender: Any) {
        self.mapKit.setRegion(self.currentRegion!, animated: true)
    }
}

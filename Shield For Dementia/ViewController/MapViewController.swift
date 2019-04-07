//
//  MapViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 8/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var annotationList = [FencedAnnotation]()
    private var currentLocation: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()
    //
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.tapped(_:)))
    
    // Michael, Computer Program, (stackoverflow, 2018)
    @objc func tapped(_ sender: UITapGestureRecognizer)
    {
        //if annotationView?.isSelected,
        print("tapped ",sender)
        // play sound
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        
        let requestURL = "https://sqbk9h1frd.execute-api.us-east-2.amazonaws.com/IEProject/ieproject/hospital/getallhospitalinfo"
        let task = URLSession.shared.dataTask(with: URL(string: requestURL)!){ data, response, error in
            if error != nil{
                print("error occured")
                DispatchQueue.main.sync{
                    self.displayAlert(title: "Error", message: "An error occured, please try later.")
                }
            }
            else{
                let responseString = String(data: data!, encoding: String.Encoding.utf8)! as String
                
                
                
                DispatchQueue.main.sync{
                    
                    if responseString != "[]"{
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as? [Any]
                            
                            for a in json!{
                                var b = a as! NSDictionary
                                var newAnnotation = FencedAnnotation(newTitle: b.value(forKey: "name") as! String,newSubtitle: b.value(forKey: "road_name") as! String + ", " + (b.value(forKey: "postcode") as! String),lat: b.value(forKey: "latitude") as! Double, long: b.value(forKey: "longitude") as! Double)
                                
                                
                                self.addAnnotation(annotation: newAnnotation)
                                
                            }
                            
                        }
                        catch{
                            
                        }
                    }
                }
            }
        }
        task.resume()
        configureLocationServices()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let location: FencedAnnotation = FencedAnnotation(newTitle: "Melbourne City", newSubtitle: "Our location right now", lat: -37.81361, long: 144.9631)
        //addAnnotation(annotation: location)
        focusOn(annotation: location)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func configureLocationServices(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
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

extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let latestLocation = locations.first else {return}
        currentLocation = latestLocation.coordinate
    }
}

extension MapViewController: MKMapViewDelegate{
    
    
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
        
        let sizeChange = CGSize(width: 30, height: 30)
        let origin = CGPoint(x: 0, y: 0)
        UIGraphicsBeginImageContextWithOptions(sizeChange, false, 0.0)
        
        var imagea = UIImage(named: "hospital")
        imagea?.draw(in: CGRect(origin: origin, size: sizeChange))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        annotationView?.image = newImage
        annotationView?.image?.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        annotationView?.canShowCallout = true
        return annotationView
    }
    //
    //    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    //
    //    }
    //
    //    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    //
    //    }
    //
    //
    //
    //    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //    }
}

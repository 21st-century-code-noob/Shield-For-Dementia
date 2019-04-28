//
//  CustomViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 25/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit

class CustomViewController: UIViewController, UIGestureRecognizerDelegate{
    
    var latTextField : UITextField?
    var longTextField : UITextField?
    
    var tapRecognizer: UITapGestureRecognizer?
    
    @IBAction func saveLocation(_ sender: Any) {
        if mkMapView.annotations.count == 0{
            displayMessage("Could not save the Location", "Error!")
        }
        else{
            
            let lat: Double = (mkMapView.annotations.first?.coordinate.latitude)!
            let long: Double = (mkMapView.annotations.first?.coordinate.longitude)!
            latTextField!.text = "\(lat)"
            longTextField!.text = "\(long)"
            CBToast.showToastAction(message: "Latitude and Longitude have been updated!")
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @IBOutlet weak var mkMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let location: FencedAnnotation = FencedAnnotation(newTitle: "Monash University - Caulfield", newSubtitle: "Our location right now", lat: -37.877211, long: 145.044856)
        foucusOn(annotation: location)
        
        //https://stackoverflow.com/questions/34431459/ios-swift-how-to-add-pinpoint-to-map-on-touch-and-get-detailed-address-of-th
        //Moriya, Computer program, (stackoverflow.com, 2018)
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer?.delegate = self as UIGestureRecognizerDelegate
        mkMapView.addGestureRecognizer(tapRecognizer!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func foucusOn(annotation: MKAnnotation){
        self.mkMapView.centerCoordinate = annotation.coordinate
        self.mkMapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        self.mkMapView.setRegion(zoomRegion, animated: true)
    }
    
    //Moriya, Computer program, (stackoverflow.com, 2018)
    @IBAction func handleTap(_sender: UITapGestureRecognizer) {
        
        let location = tapRecognizer?.location(in: mkMapView)
        let coordinate = mkMapView.convert(location!,toCoordinateFrom: mkMapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mkMapView.removeAnnotations(mkMapView.annotations)
        mkMapView.addAnnotation(annotation)
    }
    
    func displayMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


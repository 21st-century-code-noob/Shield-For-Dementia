//
//  RouteDetailTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by apple on 10/5/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class RouteDetailTableViewController: UITableViewController {

    var routeName: String?
    var route: MKOverlay?
    var startEndPoint: [MKAnnotation] = []
    let patientId = UserDefaults.standard.value(forKey: "patientId") as! String
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage()
    var pointList: [CLLocationCoordinate2D] = []
    
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var DurationLabel: UILabel!
    
    @IBAction func updateRoute(_ sender: UIButton) {
        let popup = PopupViewController.create() as! PopupViewController
        let sbPopup = SBCardPopupViewController(contentViewController: popup)
        popup.routeNameLabel.text = self.routeName
        popup.routeName = self.routeName
        sbPopup.show(onViewController: self)
    }
    
    @IBAction func deleteRoute(_ sender: Any) {
        
    self.databaseRef.child("users").child(patientId).child("routeList").child(routeName!).removeValue()
    mkMapView.removeOverlay(mkMapView!.overlays[0])
    mkMapView.removeAnnotations(startEndPoint)
    DurationLabel.text = "0 seconds"

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mkMapView.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(route != nil){
            mkMapView.removeOverlay(mkMapView!.overlays[0])
            mkMapView.removeAnnotations(startEndPoint)
            DurationLabel.text = "0 seconds"
        }
        
        getRoute()
    }
    
    func getRoute(){
        databaseRef.child("users").child(patientId).child("routeList").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let response = snapshot.value as? NSDictionary
            if response != nil{
                var result = response!.value(forKey: self.routeName!) as? NSDictionary
                if(result != nil){
                    var durationResult = result!.value(forKey: "duration") as? Int
                    var pointListResult = result!.value(forKey: "pointList") as? NSArray
                    var i = 0
                    while (i < pointListResult!.count){
                        var info = pointListResult![i] as! NSDictionary
                        var lat = info.value(forKey: "lat") as! Double
                        var long = info.value(forKey: "long") as! Double
                        var point = CLLocationCoordinate2DMake(lat, long)
                        self.pointList.append(point)
                        i += 1
                    }
                    
                    var time = durationResult!.quotientAndRemainder(dividingBy: 60)
                    self.DurationLabel.text = String(time.quotient) + " minutes and " + String(time.remainder) + " seconds"
                    self.mkMapView.addOverlay(MKPolyline(coordinates: self.pointList, count: self.pointList.count))
                    self.route = MKPolyline(coordinates: self.pointList, count: self.pointList.count)
                    var a = FencedAnnotation(newTitle: "Start", newSubtitle: "", lat: self.pointList[0].latitude, long: self.pointList[0].longitude)
                    var b = FencedAnnotation(newTitle: "End", newSubtitle: "", lat: self.pointList[self.pointList.count-1].latitude, long: self.pointList[self.pointList.count-1].longitude)
                    self.startEndPoint.append(a)
                    self.startEndPoint.append(b)
                    self.mkMapView.addAnnotations(self.startEndPoint)
                    self.focusOn(annotation: FencedAnnotation(newTitle: "End", newSubtitle: "", lat: (self.pointList[self.pointList.count-1].latitude + self.pointList[0].latitude)/2, long: (self.pointList[self.pointList.count-1].longitude + self.pointList[0].longitude)/2))
                    
                }
                
            }
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func focusOn(annotation: MKAnnotation){
        self.mkMapView.centerCoordinate = annotation.coordinate
        self.mkMapView.selectAnnotation(annotation,animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        self.mkMapView.setRegion(zoomRegion, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RouteDetailTableViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 3
        return renderer
        
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
//        if annotationView == nil{
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
//        }
//
//        if annotation.isKind(of: MKUserLocation.self){
//            return nil
//        }
//
//        //annotationView?.leftCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        return annotationView
//    }
    
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

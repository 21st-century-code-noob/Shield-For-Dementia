//
//  RecreationalAnnotation.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/5/12.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import MapKit

class RecreationalAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var address: String?
    
    init(newTitle: String, newAddress: String, lat: Double, long: Double) {
        title = newTitle
        address = newAddress
        coordinate = CLLocationCoordinate2D()
        coordinate.latitude = lat
        coordinate.longitude = long
    }
}

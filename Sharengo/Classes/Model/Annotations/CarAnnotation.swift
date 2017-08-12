//
//  CarAnnotation.swift
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import GoogleMaps

class CarAnnotation: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var marker: UIImage
    var car:Car
    
    init(position: CLLocationCoordinate2D, car: Car, carBooked: Car?) {
        self.position = position
        self.car = car
        if car.booked || car.opened {
            self.marker = UIImage(named: "ic_auto_big")!
        } else if car.nearest && carBooked == nil {
            self.marker = UIImage(named: "ic_auto_big")!
        } else {
            self.marker = UIImage(named: "ic_auto")!
        }
    }
}

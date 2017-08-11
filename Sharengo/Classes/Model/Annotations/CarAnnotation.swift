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
    var car:Car?
    
    init(position: CLLocationCoordinate2D) {
        self.position = position
        if let car = self.car {
            if car.nearest || car.booked || car.opened {
                self.marker = UIImage(named: "ic_auto_big")!
                return
            }
        }
        self.marker = UIImage(named: "ic_auto")!
    }
}

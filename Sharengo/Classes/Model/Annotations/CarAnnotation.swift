//
//  CarAnnotation.swift
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import GoogleMaps

/**
 CarAnnotation class is the GMUClusterItem that application uses to show car location (single pin or cluster)
 */
public class CarAnnotation: NSObject, GMUClusterItem {
    /// Variable used to save the position of the marker
    public var position: CLLocationCoordinate2D
    /// Variable used to save the image to show in the marker
    public var marker: UIImage
    /// Variable used to save the car
    public var car: Car
    
    // MARK: - Init methods
    
    public init(position: CLLocationCoordinate2D, car: Car, carBooked: Car?) {
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

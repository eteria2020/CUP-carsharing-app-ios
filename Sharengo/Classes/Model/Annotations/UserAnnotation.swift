//
//  UserAnnotation.swift
//
//  Created by Dedecube on 05/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

/** 
 UserAnnotation class is the GMSMarker that application uses to show user location
 */
public class UserAnnotation: GMSMarker {
    /// Variable used to get the image to show in the marker
    public var image: UIImage = UIImage(named: "ic_user")!
    
    func updateImage(carTrip: CarTrip?) {
        if carTrip != nil {
            self.image = CoreController.shared.pulseYellow
        } else {
            self.image = UIImage(named: "ic_user")!
        }
    }
}

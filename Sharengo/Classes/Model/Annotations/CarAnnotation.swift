//
//  CarAnnotation.swift
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import MapKit

class CarAnnotation: NSObject, MKAnnotation
{
    var coordinate = CLLocationCoordinate2D()
    var title: String?
    var car:Car?
}

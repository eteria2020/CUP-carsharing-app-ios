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
    lazy var image: UIImage = self.getImage()
    
    // MARK: - Lazy methods
    
    func getImage() -> UIImage {
        if let car = self.car {
            if car.nearest {
                // TODO: execute animation
                return UIImage(named: "ic_auto_vicina")!
            }
        }
        return UIImage(named: "ic_auto")!
    }
}

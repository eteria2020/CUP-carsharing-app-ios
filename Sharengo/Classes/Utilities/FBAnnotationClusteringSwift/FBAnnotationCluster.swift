//
//  FBAnnotationCluster.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import GoogleMaps

open class FBAnnotationCluster: GMSMarker {
    
    open var coordinate = CLLocationCoordinate2D()
    open var subtitle: String?
    
    open var annotations: [GMSMarker] = []
}

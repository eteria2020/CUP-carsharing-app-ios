//
//  RouteStepRouteStep.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

public class RouteStep: ModelType, Decodable {
    
    var points: String?
    var distance: Int?
    var duration: Int?
  
    required public init?(json: JSON) {
        points = "overview_polyline.points" <~~ json
        if let legs: [JSON] = "legs" <~~ json {
            if legs.count > 0 {
                let leg = legs[0]
                distance = "distance.value" <~~ leg
                duration = "duration.value" <~~ leg
            }
        }
    }
}

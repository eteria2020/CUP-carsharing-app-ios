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

/**
 The Route Step model is used to represent singular step of a route.
 */
public class RouteStep: ModelType, Gloss.Decodable {
    /// Points
    public var points: String?
    /// Distance
    public var distance: Int?
    /// Duration of step
    public var duration: Int?
  
    // MARK: - Init methods
    
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

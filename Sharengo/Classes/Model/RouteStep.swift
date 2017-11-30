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
 The Route Step model is used to represent singular step of a google route.
 */
public class RouteStep: ModelType, Decodable {
    /// Polyline points (used from google to create path)
    public var points: String?
    /// Distance from user
    public var distance: Int?
    /// Walking duration from user
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
